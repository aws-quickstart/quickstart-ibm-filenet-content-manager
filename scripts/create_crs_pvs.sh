#!/bin/bash

# Create directories on Bastion host to map EFS volumes
if (sudo mkdir -p /data/ecm/crs/cfgstore/) ; then
  echo "Created /data/ecm/crs/cfgstore/ successfully"
else
  echo "Unable to create /data/ecm/crs/cfgstore/"
  exit 1
fi

if (sudo mkdir -p /data/ecm/crs/logstore/) ; then
  echo "Created /data/ecm/crs/logstore/ successfully"
else
  echo "Unable to create /data/ecm/crs/logstore/"
  exit 1
fi

# Create config store PVC
crscfgstore_pv=$(runuser -l ec2-user -c "kubectl get pvc crs-cfgstore-pvc -o jsonpath="{.spec.volumeName}"")
crscfgstore_pv_path=$(runuser -l ec2-user -c "kubectl get pv $crscfgstore_pv -o jsonpath="{.spec.nfs.path}"")
crscfgstore_pv_server=$(runuser -l ec2-user -c "kubectl get pv $crscfgstore_pv -o jsonpath="{.spec.nfs.server}"")

# Mount config store PVC
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $crscfgstore_pv_server":"$crscfgstore_pv_path /data/ecm/crs/cfgstore
echo "Finished mounting crs-cfgstore-pvc"

# Create log store PVC
crslogstore_pv=$(runuser -l ec2-user -c "kubectl get pvc crs-logstore-pvc -o jsonpath="{.spec.volumeName}"")
crslogstore_pv_path=$(runuser -l ec2-user -c "kubectl get pv $crslogstore_pv -o jsonpath="{.spec.nfs.path}"")
crslogstore_pv_server=$(runuser -l ec2-user -c "kubectl get pv $crslogstore_pv -o jsonpath="{.spec.nfs.server}"")

# Mount log store PVC
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $crslogstore_pv_server":"$crslogstore_pv_path /data/ecm/crs/logstore
echo "Finished mounting crs-logstore-pvc"
