scp scripts/codeharbor-kind-deploy.sh debian@57.128.61.186:~
ssh debian@57.128.61.186 "chmod +x ~/codeharbor-kind-deploy.sh"
ssh debian@57.128.61.186 "bash ~/codeharbor-kind-deploy.sh"    
