#!/bin/bash

# Extract parameter values from the command line
cpeIngress=$1
CPE_PortNumber=$2
CPE_BootstrapUserPassword=$3
LDAP_ServerHost=$4
LDAP_BindDN="CN=P8Admin,CN=Users,DC=$5,DC=$6"
LDAP_BindPassword=$3
LDAP_BaseDN="DC=$5,DC=$6"

# Pre-defined parameter values
CPE_BootstrapUsername="P8Admin"
p8DomainName="P8Domain"
LDAP_Type="AD"
LDAP_ServerPort="389"
p8DomainAdminUsers="P8Admin"
p8DomainUsers="#AUTHENTICATED-USERS"

# Computed parameter values
cpeMachine_nodeName=$(runuser -l ec2-user -c "kubectl get ingress/$cpeIngress -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}'")
PodName=$(runuser -l ec2-user -c "kubectl get pods | grep cpe")
CPE_PodName=$(echo $PodName | awk '{print $1}')
CPE_LogLocation="/data/ecm/cpe/logstore/$CPE_PodName"

# Set timeout iterations in 30s intervals
TIME_OUT=30

# Upgrade to Java 8
yum install java-1.8.0 -y
/usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
/usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac

# Extract CPE libraries and jar files
i=0
while(($i<$TIME_OUT))
do
	if [[ -f /home/ec2-user/CPELibs.zip ]]; then
		unzip -o CPELibs.zip
		chown -R ec2-user:ec2-user /home/ec2-user
		break
	else
		echo "CPE Library archive file not yet downloaded. Wait 30 seconds and retry again...."
		sleep 30s
		let i++
	fi
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "CPE Library archive was not downloaded successfully. Exiting..."
        exit 1
fi

# Set Java classpath to include required jar files
LIBCLASSPATH="/home/ec2-user/cpelib/CPEUtils.jar:/home/ec2-user/cpelib/Jace.jar:/home/ec2-user/cpelib/log4j.jar:/home/ec2-user/cpelib/stax-api.jar:/home/ec2-user/cpelib/xercesImpl.jar:/home/ec2-user/cpelib/xlxpScanner.jar:/home/ec2-user/cpelib/xlxpScannerUtils.jar"

# Check whether CPE is online - then create the GCD
i=0
while(($i<$TIME_OUT))
do
    PodsOnline=$(runuser -l ec2-user -c "kubectl get deployment fncm-cpe -o jsonpath='{.status.readyReplicas}'")
    if [[ $PodsOnline -eq "3" ]]; then
		isCPEOnLine=$(curl -s -I http://$cpeMachine_nodeName:$CPE_PortNumber/acce | grep 302)
		if [[ "$isCPEOnLine" != "" ]] ;then
			isCPEReady=$(cat $CPE_LogLocation/messages.log | grep "DetailedStatusReport.*Initialization successful")
			if [[ "$isCPEReady" != "" ]]; then
				java -cp $LIBCLASSPATH com.ibm.CETools 'createDomain' $cpeMachine_nodeName $CPE_PortNumber $CPE_BootstrapUsername $CPE_BootstrapUserPassword $p8DomainName $LDAP_Type $LDAP_ServerHost $LDAP_ServerPort $LDAP_BindDN $LDAP_BindPassword $LDAP_BaseDN $LDAP_BaseDN $p8DomainAdminUsers $p8DomainUsers
				break
			else
				echo "$i. CPE is not ready yet, wait 30 seconds and retry again...."
				sleep 30s
				let i++
			fi
		else
			echo "$i. CPE application has not started yet, wait 30 seconds and retry again...."
			sleep 30s
			let i++
		fi
	else
		echo "$i. CPE pods have not started yet, wait 30 seconds and retry again...."
		sleep 30s
		let i++
	fi
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "CPE has not started successfully. Exiting..."
        exit 1
fi
