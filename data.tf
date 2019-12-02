data "ibm_resource_group" "group" {
  name = "CDE"
}

locals {
  BASENAME = "lonvpc"
  ZONE1    = "eu-gb-1"
  ZONE2    = "eu-gb-2"
}

data ibm_is_image "ubuntu" {
  name = "ubuntu-18.04-amd64"
}

data ibm_is_ssh_key "ssh_key_id" {
  name = "${var.ssh_key}"
}
