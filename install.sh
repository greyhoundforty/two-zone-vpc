#!/bin/bash 

DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install unzip build-essential git curl -y

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


cat << EOF > /etc/consul.d/consul.hcl
datacenter = "vpc-consul"
data_dir = "/opt/consul"
encrypt = "SD5m2updmrGmb4Yv1E/dK22F2YBD7APKf+WRALNGgCU="
bind_addr = "BINDIP"
node_name = "$(hostname -s)"
acl = {
    enabled = true,
    default_policy = "allow",
    enable_token_persistence = true
    tokens = {
      "master" =  "c4f6eff8cb457a9bb36a5e3504a5b8d4"
    }
}
EOF

chown --recursive consul:consul /etc/consul.d
chmod 640 /etc/consul.d/consul.hcl

mkdir --parents /etc/consul.d
chown --recursive consul:consul /etc/consul.d
chmod 640 /etc/consul.d/server.hcl

cat << EOF > /etc/consul.d/server.hcl
server = true
bootstrap_expect = 3
ui = true
EOF

systemctl enable consul

