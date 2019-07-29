DOMAIN=local.local

CA_CONF=openssl-root.cnf
CA_DIR=./ca
CA_KEY=${CA_DIR}/ca.${DOMAIN}.key.pem
CA_CRT=${CA_DIR}/ca.${DOMAIN}.crt.pem
CA_SUB="/C=CA/ST=${DOMAIN}/O=${DOMAIN}/CN=root"

SRV_DIR=./srv
SRV_KEY=${SRV_DIR}/wildcard.${DOMAIN}.key.pem
SRV_CRT=${SRV_DIR}/wildcard.${DOMAIN}.crt.pem
SRV_CSR=${SRV_DIR}/wildcard.${DOMAIN}.csr.pem
SRV_SUB="/C=CA/ST=${DOMAIN}/O=${DOMAIN}/CN=*.${DOMAIN}"

echo --- Prepare directory
mkdir ${CA_DIR} ${CA_DIR}/crl ${CA_DIR}/certs ${CA_DIR}/new_certs ${SRV_DIR}
touch ${CA_DIR}/index.txt
echo 1000 > ${CA_DIR}/serial

sed -i "s/__DOMAIN__/$DOMAIN/g" ${CA_CONF}

echo --- Generate Root Key and Certificate
openssl req \
-config ${CA_CONF} \
-new -x509 -nodes -days 3650 \
-extensions v3_ca \
-keyout ${CA_KEY} \
-out ${CA_CRT} \
-subj ${CA_SUB}

echo --- Generate Server Key
openssl genrsa -out ${SRV_KEY} 2048

echo --- Generate Server CSR
openssl req -config ${CA_CONF} \
-key ${SRV_KEY} \
-new -sha256 -out ${SRV_CSR} \
-subj ${SRV_SUB}

echo --- Generate Server Certificate
openssl ca -config ${CA_CONF} \
-extensions server_cert -days 3650 -notext -md sha256 \
-in ${SRV_CSR} \
-out ${SRV_CRT} <<EOF
y
y
EOF

echo
echo --- CA Certificate:
echo ${CA_CRT}
echo --- Server Certificate:
echo ${SRV_KEY}
echo ${SRV_CRT}
