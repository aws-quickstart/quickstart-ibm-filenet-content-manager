#!/bin/bash
# Container configuration ldap file updates

# Timeout value for file download
TIME_OUT=15

# extract command-line options into variables.
Hostname=$1
BaseDN1=$3
BaseDN2=$4

# Set classpath to include required jar files
LIBCLASSPATH="/home/ec2-user/plugins/com.ibm.ws.runtime.jar:/home/ec2-user/lib/bootstrap.jar:/home/ec2-user/plugins/com.ibm.ws.emf.jar:/home/ec2-user/lib/ffdc.jar:/home/ec2-user/plugins/org.eclipse.emf.ecore.jar:/home/ec2-user/plugins/org.eclipse.emf.common.jar"

# Encode password using security utility function - PasswordEncoder
Password=$(java -cp $LIBCLASSPATH com.ibm.ws.security.util.PasswordEncoder $2 | awk '{print $8}')
ADPassword=${Password//\"}

# Update hostname, BaseDN and Password in ldap XML file
i=0
while(($i<$TIME_OUT*2))
do
	if [[ -f /home/ec2-user/ldap.xml ]]; then
		sed -i -e "s/ad_hostname/$Hostname/g" /home/ec2-user/ldap.xml
		sed -i -e "s/ad_password/$ADPassword/g" /home/ec2-user/ldap.xml
		sed -i -e "s/ad_basedn1/$BaseDN1/g" /home/ec2-user/ldap.xml
		sed -i -e "s/ad_basedn2/$BaseDN2/g" /home/ec2-user/ldap.xml
		break
	else
		echo "Container LDAP XML file not yet downloaded. Wait 30 seconds and retry again...."
		sleep 30s
		let i++
	fi
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "Container LDAP XML file was not downloaded successfully. Exiting..."
        exit 1
fi

echo "Ldap file updates complete."
