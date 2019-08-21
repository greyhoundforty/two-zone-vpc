provider "ibm" {
  ibmcloud_api_key   = "${var.ibm_bx_api_key}"
  generation         = 1
  region             = "eu-gb"
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key  = "${var.ibm_sl_api_key}"
}
