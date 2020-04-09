#!/bin/bash

# Create directories on Bastion host to map EFS volumes
if (sudo mkdir -p /data/ecm/cmis/cfgstore/) ; then
  echo "Created /data/ecm/cmis/cfgstore/ successfully"
else
  echo "Unable to create /data/ecm/cmis/cfgstore/"
  exit 1
fi

if (sudo mkdir -p /data/ecm/cmis/logstore/) ; then
  echo "Created /data/ecm/cmis/logstore/ successfully"
else
  echo "Unable to create /data/ecm/cmis/logstore/"
  exit 1
fi

# Create config store PVC
cmiscfgstore_pv=$(runuser -l ec2-user -c "kubectl get pvc cmis-cfgstore-pvc -o jsonpath="{.spec.volumeName}"")
cmiscfgstore_pv_path=$(runuser -l ec2-user -c "kubectl get pv $cmiscfgstore_pv -o jsonpath="{.spec.nfs.path}"")
cmiscfgstore_pv_server=$(runuser -l ec2-user -c "kubectl get pv $cmiscfgstore_pv -o jsonpath="{.spec.nfs.server}"")

# Mount config store PVC
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $cmiscfgstore_pv_server":"$cmiscfgstore_pv_path /data/ecm/cmis/cfgstore
echo "Finished mounting cmis-cfgstore-pvc"

# Create log store PVC
cmislogstore_pv=$(runuser -l ec2-user -c "kubectl get pvc cmis-logstore-pvc -o jsonpath="{.spec.volumeName}"")
cmislogstore_pv_path=$(runuser -l ec2-user -c "kubectl get pv $cmislogstore_pv -o jsonpath="{.spec.nfs.path}"")
cmislogstore_pv_server=$(runuser -l ec2-user -c "kubectl get pv $cmislogstore_pv -o jsonpath="{.spec.nfs.server}"")

# Mount log store PVC
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $cmislogstore_pv_server":"$cmislogstore_pv_path /data/ecm/cmis/logstore
echo "Finished mounting cmis-logstore-pvc"
