data "ibm_resource_group" "group" {
  name = "CDE"
}

locals {
  BASENAME = "lonvpc"
  ZONE1    = "eu-gb-1"
  ZONE2    = "eu-gb-2"
}

resource ibm_is_vpc "vpc" {
  name           = "${local.BASENAME}-vpc"
  resource_group = "${data.ibm_resource_group.group.id}"
}

resource ibm_is_security_group "sg1" {
  name           = "${local.BASENAME}-sg1"
  vpc            = "${ibm_is_vpc.vpc.id}"
  resource_group = "${data.ibm_resource_group.group.id}"
}

# allow all incoming network traffic on port 22
resource "ibm_is_security_group_rule" "ingress_ssh_all" {
  group     = "${ibm_is_security_group.sg1.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_public_gateway" "zone1gateway" {
  name = "${local.BASENAME}-${local.ZONE1}-gw"
  vpc  = "${ibm_is_vpc.vpc.id}"
  zone = "${local.ZONE1}"
}

resource "ibm_is_public_gateway" "zone2gateway" {
  name = "${local.BASENAME}-${local.ZONE2}-gw"
  vpc  = "${ibm_is_vpc.vpc.id}"
  zone = "${local.ZONE2}"
}

resource ibm_is_subnet "subnet1" {
  name                     = "${local.BASENAME}-subnet1"
  vpc                      = "${ibm_is_vpc.vpc.id}"
  zone                     = "${local.ZONE1}"
  total_ipv4_address_count = 256
  public_gateway = "${ibm_is_public_gateway.zone1gateway.id}"
}

resource ibm_is_subnet "subnet2" {
  name                     = "${local.BASENAME}-subnet2"
  vpc                      = "${ibm_is_vpc.vpc.id}"
  zone                     = "${local.ZONE2}"
  total_ipv4_address_count = 256
  public_gateway = "${ibm_is_public_gateway.zone2gateway.id}"
}

data ibm_is_image "ubuntu" {
  name = "ubuntu-18.04-amd64"
}

data ibm_is_ssh_key "ssh_key_id" {
  name = "${var.ssh_key}"
}

resource ibm_is_instance "vsi1" {
  name           = "${local.BASENAME}-vsi1"
  vpc            = "${ibm_is_vpc.vpc.id}"
  zone           = "${local.ZONE1}"
  keys           = ["${data.ibm_is_ssh_key.ssh_key_id.id}"]
  image          = "${data.ibm_is_image.ubuntu.id}"
  profile        = "bc1-4x16"
  user_data      = "${file("install.yml")}"
  resource_group = "${data.ibm_resource_group.group.id}"

  primary_network_interface = {
    subnet          = "${ibm_is_subnet.subnet1.id}"
    security_groups = ["${ibm_is_security_group.sg1.id}"]
  }
}

resource ibm_is_instance "vsi2" {
  name           = "${local.BASENAME}-vsi2"
  vpc            = "${ibm_is_vpc.vpc.id}"
  zone           = "${local.ZONE2}"
  keys           = ["${data.ibm_is_ssh_key.ssh_key_id.id}"]
  image          = "${data.ibm_is_image.ubuntu.id}"
  profile        = "bc1-4x16"
  user_data      = "${file("install.yml")}"
  resource_group = "${data.ibm_resource_group.group.id}"

  primary_network_interface = {
    subnet          = "${ibm_is_subnet.subnet2.id}"
    security_groups = ["${ibm_is_security_group.sg1.id}"]
  }
}

resource ibm_is_floating_ip "fip1" {
  name   = "${local.BASENAME}-fip1"
  target = "${ibm_is_instance.vsi1.primary_network_interface.0.id}"
}

resource ibm_is_floating_ip "fip2" {
  name   = "${local.BASENAME}-fip2"
  target = "${ibm_is_instance.vsi2.primary_network_interface.0.id}"
}

output instance1_ssh {
  value = "ssh ryan@${ibm_is_floating_ip.fip1.address}"
}

output instance2_ssh {
  value = "ssh ryan@${ibm_is_floating_ip.fip2.address}"
}
