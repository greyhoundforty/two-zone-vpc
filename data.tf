data "ibm_resource_group" "group" {
  name = "CDE"
}

locals {
  BASENAME = "${var.basename}"
  ZONE1    = "${var.region}-1"
  ZONE2    = "${var.region}-2"
  ZONE3    = "${var.region}-3"
}

data ibm_is_image "ubuntu" {
  name = "ubuntu-18.04-amd64"
}

data ibm_is_ssh_key "ssh_key_id" {
  name = "${var.ssh_key}"
}
