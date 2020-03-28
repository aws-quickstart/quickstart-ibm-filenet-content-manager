#!/bin/bash
# Copy container configuration files to overrides folder

# Timeout value for file download / update
TIME_OUT=30

# Check for encoded password in XML files
for j in ldap.xml; do
    i=0
    while(($i<$TIME_OUT))
    do
        if [[ -f /home/ec2-user/$j ]]; then
            encodedpass=$(grep xor $j)
            if [[ $encodedpass = "" ]]; then
                echo "Password not yet updated in file: $j Wait 30 seconds and retry again..."
                sleep 30s
                let i++
            else
                break
            fi
        else
            echo "XML file $j not yet downloaded. Wait 30 seconds and retry again...."
            sleep 30s
            let i++
        fi
    done
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "Container XML files were not updated successfully. Exiting..."
        exit 1
fi

# Copy files to CRS container overrides folder
for j in ldap.xml; do
    i=0
    while(($i<$TIME_OUT))
    do
        if [[ -f /home/ec2-user/$j ]]; then
            cp /home/ec2-user/$j /data/ecm/cmis/cfgstore
            break
        else
            echo "Configuration file $j not yet downloaded. Wait 30 seconds and retry again...."
            sleep 30s
            let i++
        fi
    done
done
if [[ $i -eq $TIME_OUT ]]; then
        echo "CMIS container files were not copied successfully. Exiting..."
        exit 1
fi
