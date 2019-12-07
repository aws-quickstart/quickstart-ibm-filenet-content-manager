#!/bin/bash
# Container configuration file updates

# Timeout value for file download
TIME_OUT=15

# extract command-line options into variables.
DBName=$1
Endpoint=$3

# Extract Security Utility libraries and plugin files
i=0
while(($i<$TIME_OUT*2))
do
	if [[ -f /home/ec2-user/securityUtility.zip ]]; then
		unzip -o securityUtility.zip
		chown -R ec2-user:ec2-user /home/ec2-user
		break
	else
		echo "Security Utilities file not yet downloaded. Wait 30 seconds and retry again...."
		sleep 30s
		let i++
	fi
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "Security utilities was not downloaded successfully. Exiting..."
        exit
fi

# Set classpath to include required jar files
LIBCLASSPATH="/home/ec2-user/plugins/com.ibm.ws.runtime.jar:/home/ec2-user/lib/bootstrap.jar:/home/ec2-user/plugins/com.ibm.ws.emf.jar:/home/ec2-user/lib/ffdc.jar:/home/ec2-user/plugins/org.eclipse.emf.ecore.jar:/home/ec2-user/plugins/org.eclipse.emf.common.jar"

# Encode password using security utility function - PasswordEncoder
Password=$(java -cp $LIBCLASSPATH com.ibm.ws.security.util.PasswordEncoder $2 | awk '{print $8}')
DBPassword=${Password//\"}

# Update database endpoint address, database name and password in the XML files
i=0
while(($i<$TIME_OUT*2))
do
	if [[ -f /home/ec2-user/GCD.xml && /home/ec2-user/OS1.xml && /home/ec2-user/ICNDS.xml ]]; then
		for i in GCD.xml OS1.xml ICNDS.xml; do \
			sed -i -e "s/rds_endpoint/$Endpoint/g" /home/ec2-user/$i; \
			sed -i -e "s/rds_db/$DBName/g" /home/ec2-user/$i; \
			sed -i -e "s/rds_password/$DBPassword/g" /home/ec2-user/$i; \
		done
		break
	else
		echo "Container database XML files not yet downloaded. Wait 30 seconds and retry again...."
		sleep 30s
		let i++
	fi
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "Container database XML files were not downloaded successfully. Exiting..."
        exit
fi

echo "Database file updates complete."
