#!/bin/bash

DOMAIN=$1
DAYS=3650 # 10yrs

CA_TMP=./ca.cnf.template
CA_DIR=./ca/${DOMAIN}
CA_PRE=./ca/${DOMAIN}/ca.${DOMAIN}
CA_CNF=${CA_PRE}.cnf
CA_KEY=${CA_PRE}.key.pem
CA_CRT=${CA_PRE}.crt.pem
CA_DER=${CA_PRE}.crt.der
CA_SUB="/C=CA/ST=${DOMAIN}/O=${DOMAIN}/CN=${DOMAIN}"

SERIAL=1000

SRV_DIR=./srv
SRV_PRE=${SRV_DIR}/wildcard.${DOMAIN}
SRV_KEY=${SRV_PRE}.key.pem
SRV_CRT=${SRV_PRE}.crt.pem
SRV_DER=${SRV_PRE}.crt.der
SRV_CSR=${SRV_PRE}.csr.pem
SRV_SUB="/C=CA/ST=${DOMAIN}/O=${DOMAIN}/CN=*.${DOMAIN}"

function usage () {
	if [[ "$DOMAIN" = '' ]]
	then
		echo "Usage: cert-get.sh <domain>"
		exit 1
	fi
}

function ca_prep () {
	echo --- Prepare directory
	mkdir -p ${CA_DIR} ${CA_DIR}/crl ${CA_DIR}/certs ${CA_DIR}/new_certs ${SRV_DIR}
	echo ${SERIAL} > ${CA_DIR}/serial
	touch ${CA_DIR}/index.txt
	sed "s/__DOMAIN__/$DOMAIN/g" ${CA_TMP} > ${CA_CNF}
}

function ca_gen () {
	echo --- Generate Root Key and Certificate
	openssl req \
	-config ${CA_CNF} \
	-new -x509 -nodes -days $DAYS \
	-extensions v3_ca \
	-keyout ${CA_KEY} \
	-out ${CA_CRT} \
	-subj ${CA_SUB}

	# Create DER
	openssl x509 -in ${CA_CRT} -outform der -out ${CA_DER}
}

function cert_gen () {
	echo
	echo --- Generate Server Key
	openssl genrsa -out ${SRV_KEY} 2048

	echo --- Generate Server CSR
	openssl req -config ${CA_CNF} \
	-key ${SRV_KEY} \
	-new -sha256 -out ${SRV_CSR} \
	-subj ${SRV_SUB}

	echo --- Generate Server Certificate
	openssl ca -config ${CA_CNF} \
	-extensions server_cert -days $DAYS -notext -md sha256 \
	-in ${SRV_CSR} \
	-out ${SRV_CRT} <<EOF
y
y
EOF

	# Create DER
	openssl x509 -in ${SRV_CRT} -outform der -out ${SRV_DER}
}

function info () {
	echo
	echo --- CA Certificate:
	echo ${CA_CRT}
	echo ${CA_DER}
	echo --- Server Certificate:
	echo ${SRV_KEY}
	echo ${SRV_CRT}
	echo ${SRV_DER}
}

usage

if [ -f ${CA_CRT} ]
then
	echo ${DOMAIN} CA exist!
else
	ca_prep
	ca_gen
fi

if [ -f ${SRV_CRT} ]
then
	echo Certificate ${SRV_CRT} exist!
else
	cert_gen
fi

info
