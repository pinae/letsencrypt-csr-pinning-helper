#!/usr/bin/env bash

echo "Length of the RSA-Key? [4096]"
read key_size
if [ "${key_size:=4096}" -lt 2048 ]; then
    key_size=4096
    echo "Key size too small. Setting to 4096."
fi
days=93
echo "Country? [DE]"
read Country
echo "State? [Berlin]"
read State
echo "City? [Berlin]"
read City
echo "Organization name? [${1}]"
read Organization
Organization=${Organization:=${1}}
echo "Organization unit? [${1}-Webmaster]"
read Organization_Unit
Organization_Unit=${Organization_Unit:=${1}"-Webmaster"}
echo "Webmaster Email? [webmaster@${1}]"
read Email
Email=${Email:="webmaster@"${1}}
DNSNames=""
for ((i=1;i <= $#;i++))
{
    eval domain_name=\$$i
    DNSNames=${DNSNames}"DNS."${i}" = "${domain_name}
    if [ ${i} -lt $# ]; then
        DNSNames=${DNSNames}$'\n'
    fi
}

openssl req -new -sha256 -nodes -out ${1}.csr -newkey rsa:${key_size} -days ${days} -keyout ${1}.key -config <(
cat <<-EOF
[req]
default_bits = ${key_size}
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=${Country:="DE"}
ST=${State:="Berlin"}
L=${City:="Berlin"}
O=${Organization}
OU=${Organization_Unit:=""}
emailAddress=${Email}
CN = ${1}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
${DNSNames}
EOF
)