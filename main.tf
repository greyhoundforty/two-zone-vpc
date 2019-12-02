resource ibm_is_vpc "vpc" {
  name           = "${local.BASENAME}-vpc"
  resource_group = "${data.ibm_resource_group.group.id}"
}

resource "ibm_is_network_acl" "default_acl" {
  name = "${local.BASENAME}-acl"

  rules = [
    {
      name        = "outbound"
      action      = "allow"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      direction   = "outbound"
    },
    {
      name        = "inbound"
      action      = "allow"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      direction   = "inbound"
    },
  ]
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
  public_gateway           = "${ibm_is_public_gateway.zone1gateway.id}"
  network_acl              = "${ibm_is_network_acl.default_acl.id}"
}

resource ibm_is_subnet "subnet2" {
  name                     = "${local.BASENAME}-subnet2"
  vpc                      = "${ibm_is_vpc.vpc.id}"
  zone                     = "${local.ZONE2}"
  total_ipv4_address_count = 256
  public_gateway           = "${ibm_is_public_gateway.zone2gateway.id}"
  network_acl              = "${ibm_is_network_acl.default_acl.id}"
}

resource ibm_is_instance "vsi1" {
  name           = "${local.BASENAME}-vsi1"
  vpc            = "${ibm_is_vpc.vpc.id}"
  zone           = "${local.ZONE1}"
  keys           = ["${data.ibm_is_ssh_key.ssh_key_id.id}"]
  image          = "${data.ibm_is_image.ubuntu.id}"
  profile        = "bc1-4x16"
  user_data      = "${file("install.sh")}"
  resource_group = "${data.ibm_resource_group.group.id}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.subnet1.id}"

    # security_groups = ["${ibm_is_security_group.sg1.id}", "${ibm_is_security_group.consul.id}"]
  }
}

resource ibm_is_instance "vsi2" {
  name           = "${local.BASENAME}-vsi2"
  vpc            = "${ibm_is_vpc.vpc.id}"
  zone           = "${local.ZONE2}"
  keys           = ["${data.ibm_is_ssh_key.ssh_key_id.id}"]
  image          = "${data.ibm_is_image.ubuntu.id}"
  profile        = "bc1-4x16"
  user_data      = "${file("install.sh")}"
  resource_group = "${data.ibm_resource_group.group.id}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.subnet2.id}"

    # security_groups = ["${ibm_is_security_group.sg1.id}", "${ibm_is_security_group.consul.id}"]
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
