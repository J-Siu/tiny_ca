### Background

As browsers are getting more secure and packed with more safeguards to prevent malicious actors from doing their biddings, they are becoming much less friendly with self-signed certificates. This become a pain in small lab and other wall-offed network. While using http for non-prod/testing can be the solution, it is not ideal and may create other issues.

### Goals

- Create the simplest CA setup that can be recreated and throw away at wish.
- Create one wildcard server certificate for any servers in the network.

### Fast Forward

The result is a simple script with a openssl config file that will generate a CA and a wildcard certificate.

> ***WARNING:*** This is intended for testing/throw-away environment. Don't use it for production.

#### Usage

```zsh
git clone https://github.com/J-Siu/tiny_ca.git
cd tiny_ca
tiny_ca.sh <domain>
```

#### Sample Output

```sh
$ ./tiny_ca.sh local.local
--- Prepare directory
--- Generate Root Key and Certificate
Generating a RSA private key
...................................................................+++++
................................+++++
writing new private key to './ca/local.local/ca.local.local.key.pem'
-----

--- Generate Server Key
Generating RSA private key, 2048 bit long modulus (2 primes)
.........+++++
...........+++++
e is 65537 (0x010001)
--- Generate Server CSR
--- Generate Server Certificate
Using configuration from ./ca/local.local/ca.local.local.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 4096 (0x1000)
        Validity
            Not Before: Feb  7 21:28:34 2020 GMT
            Not After : Feb  4 21:28:34 2030 GMT
        Subject:
            countryName               = CA
            stateOrProvinceName       = local.local
            organizationName          = local.local
            commonName                = *.local.local
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Cert Type:
                SSL Server
            Netscape Comment:
                OpenSSL Generated Server Certificate
            X509v3 Subject Key Identifier:
                14:5F:04:EF:39:42:8F:A3:B5:C7:21:8D:9B:7A:D9:A4:20:FB:21:EF
            X509v3 Authority Key Identifier:
                keyid:7E:B0:D5:B2:44:2A:A6:7C:2C:CB:A6:D2:7E:42:EB:2F:25:50:3C:E1
                DirName:/C=CA/ST=local.local/O=local.local/CN=root
                serial:3C:1A:88:5F:B7:71:A5:DB:4F:99:E2:6F:1C:25:D7:5E:13:79:83:17

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
Certificate is to be certified until Feb  4 21:28:34 2030 GMT (3650 days)
Sign the certificate? [y/n]:

1 out of 1 certificate requests certified, commit? [y/n]Write out database with 1 new entries
Data Base Updated

--- CA Certificate:
./ca/local.local/ca.local.local.crt.pem
./ca/local.local/ca.local.local.crt.der
--- Server Certificate:
./srv/wildcard.local.local.key.pem
./srv/wildcard.local.local.crt.pem
./srv/wildcard.local.local.crt.der
```

Install CA certificate into browser.
Install server certificate and key into webserver.

### Changelog

- 1.0.0
  - Take domain name from command line.
  - Each domain in own directory under ca directory.
  - Automatically generate der format for both ca and server cert.
  - Check if ca and server cert exist.
  - Remove OSCP and CRL extension from ca.cnf.template.

### Reference

[OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/index.html) by Jamie Nguyen.

[openssl-ca](https://www.openssl.org/docs/manmaster/man1/ca.html) man page.