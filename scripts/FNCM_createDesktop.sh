#!/bin/bash

# Extract parameter values from the command line
icnIngress=$1
ICN_PortNumber=$2
ICN_AdminPassword=$3
cpeIngress=$4
CPE_PortNumber=$5

# Pre-defined parameter values
ICN_AdminUuser="P8Admin"
DESKTOP_ID="fncm"
DESKTOP_NAME="FNCM"
DESKTOP_DESCRIPTION="Default FileNet Content Manager Desktop"
P8OS_NAME="OS1"
REPOSITORY_NAME="Default_Object_Store"
PE_CONNPT_NAME="OS1Connection"
PE_REGION_NUMBER="1"

# Computed parameter values
ICN_nodeName=$(runuser -l ec2-user -c "kubectl get ingress/$icnIngress -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}'")
CPE_nodeName=$(runuser -l ec2-user -c "kubectl get ingress/$cpeIngress -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}'")

# Determine the CPE log file location
PodName=$(runuser -l ec2-user -c "kubectl get pods | grep cpe")
CPE_PodName=$(echo $PodName | awk '{print $1}')
FN_LogLocation="/data/ecm/cpe/fnlogstore/$CPE_PodName"

# Set timeout values in minutes
TIME_OUT=30

# Extract ICN utility files
i=0
while(($i<$TIME_OUT))
do
	if [[ -f /home/ec2-user/ICNutils.zip ]]; then
		unzip -o ICNutils.zip
		chown -R ec2-user:ec2-user /home/ec2-user
		break
	else
		echo "Navigator utilities archive file not yet downloaded. Wait 30 seconds and retry again...."
		sleep 30s
		let i++
	fi
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "Navigator utilities was not downloaded successfully. Exiting..."
        exit
fi

# Restart Content Navigator pods
Pods=$(runuser -l ec2-user -c "kubectl get pods | grep icn")
icnPods=$(echo $Pods | awk '{print $1 " " $6 " " $11}')
for i in $icnPods; do
        runuser -l ec2-user -c "kubectl delete pod $i"
done

# Check whether Navigator and Object store are online - then create the Desktop and Repository
i=0
while(($i<$TIME_OUT))
do
	PodsOnline=$(runuser -l ec2-user -c "kubectl get deployment fncm-icn -o jsonpath='{.status.readyReplicas}'")
	if [[ $PodsOnline -eq "3" ]]; then
        isICNOnLine=$(curl -s -I http://$ICN_nodeName:$ICN_PortNumber/navigator | grep 302)
        if [[ "$isICNOnLine" != "" ]] ;then
			isOSReady=$(cat $FN_LogLocation/p8_server_error.log | grep "Starting queue dispatching" | grep "QueueItemDispatcher" )
			if [[ "$isOSReady" != "" ]] ;then
				python ./icnutils/bin/icndefaultdriver.py --icnURL http://$ICN_nodeName:$ICN_PortNumber/navigator/ \
				--icnAdmin $ICN_AdminUuser --icnPassd $ICN_AdminPassword --ceURL http://$CPE_nodeName:$CPE_PortNumber/wsi/FNCEWS40MTOM \
				--objStoreName $P8OS_NAME --featureList browsePane searchPane favorites workPane  --defaultFeature browsePane  \
				--desktopId $DESKTOP_ID --desktopName $DESKTOP_NAME --isDefault true --desktopDesc $DESKTOP_DESCRIPTION --applicationName FNCM Default Configuration \
				--osDisplayName $REPOSITORY_NAME --defaultRepo $REPOSITORY_NAME --connectionPoint $PE_CONNPT_NAME:$PE_REGION_NUMBER
				echo "Navigator Desktop and Repository created successfully"
				break
			else
                echo "$i. Object Store is not yet available, wait 30 seconds and retry again...."
                sleep 30s
                let i++
			fi
		else
            echo "$i. Navigator application has not started yet, wait 30 seconds and retry again...."
            sleep 30s
            let i++
        fi
	else
        echo "$i. Navigator pods have not started yet, wait 30 seconds and retry again...."
        sleep 30s
        let i++
    fi
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "Navigator not available. Exiting..."
        exit
fi
