#!/bin/bash 

INSTALLER_LOG="/run/installer.log"
touch ${INSTALLER_LOG}

update_system() {
echo "Updating System :: $(date)"

DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install unzip build-essential git curl -y
} >> ${INSTALLER_LOG}

grab_consul() {
echo "Downloading and installing consul :: $(date)"

CONSUL_VERSION="1.6.2"
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

unzip consul_${CONSUL_VERSION}_linux_amd64.zip
chown root:root consul
mv consul /usr/local/bin/
consul -autocomplete-install

mkdir --parents /etc/consul.d
useradd --system --home /etc/consul.d --shell /bin/false consul
mkdir --parents /opt/consul
chown --recursive consul:consul /opt/consul
} >> ${INSTALLER_LOG}

write_configs() {

echo "Writing configs :: $(date)"

cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


cat << EOF > /root/consul.hcl
datacenter = "vpc-consul"
data_dir = "/opt/consul"
encrypt = "ENCRYPT_KEY"
bind_addr = "BINDIP"
node_name = "$(hostname -s)"
acl = {
    enabled = true,
    default_policy = "allow",
    enable_token_persistence = true
    tokens = {
      "master" =  "ACL_TOKEN"
    }
}
EOF

cat << EOF > /root/server.hcl
server = true
bootstrap_expect = 3
ui = true
EOF
} >> ${INSTALLER_LOG}

perms_fix() {
echo "Moving files and fixing permissions :: $(date)"

mv /root/consul.hcl /etc/consul.d/consul.hcl
mv /root/server.hcl /etc/consul.d/server.hcl
chown --recursive consul:consul /etc/consul.d
chmod 640 /etc/consul.d/consul.hcl
chmod 640 /etc/consul.d/server.hcl
systemctl enable consul
} >> ${INSTALLER_LOG}




update_system
grab_consul
write_configs
perms_fix
