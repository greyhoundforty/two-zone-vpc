# Consul cluster two zone vpc example

## Variables:
**region** - The region to deploy the VPC. Possible options are: `us-south` (Dallas), `eu-gb` (London), `eu-de` (Frankfurt), `jp-tok` (Tokyo), or `au-syd` (Sydney).  
**basename** - A descriptive name for the VPC. It also gets included in a lot of the resource names.  
**ssh_key** - Name of the VPC ssh-key to assign to new instances.