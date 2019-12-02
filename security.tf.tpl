resource ibm_is_security_group "sg1" {
  name           = "${local.BASENAME}-sg1"
  vpc            = "${ibm_is_vpc.vpc.id}"
  resource_group = "${data.ibm_resource_group.group.id}"
}

resource ibm_is_security_group "consul" {
  name           = "${local.BASENAME}-consul-sg"
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

resource "ibm_is_security_group_rule" "consul_in_tcp" {
  group     = "${ibm_is_security_group.consul.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 8300
    port_max = 8302
  }
}

resource "ibm_is_security_group_rule" "consul_in_udp" {
  group     = "${ibm_is_security_group.consul.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"

  udp = {
    port_min = 8301
    port_max = 8302
  }
}

resource "ibm_is_security_group_rule" "consul_out_udp" {
  group     = "${ibm_is_security_group.consul.id}"
  direction = "outbound"
  remote    = "0.0.0.0/0"

  udp = {
    port_min = 8301
    port_max = 8302
  }
}

resource "ibm_is_security_group_rule" "servers_outbound" {
  group     = "${ibm_is_security_group.consul.id}"
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_security_group_rule" "consul_out_http" {
  group     = "${ibm_is_security_group.consul.id}"
  direction = "outbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 8500
    port_max = 8500
  }
}

resource "ibm_is_security_group_rule" "consul_in_http" {
  group     = "${ibm_is_security_group.consul.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 8500
    port_max = 8500
  }
}

resource "ibm_is_security_group_rule" "consul_out_tcp" {
  group     = "${ibm_is_security_group.consul.id}"
  direction = "outbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 8300
    port_max = 8302
  }
}