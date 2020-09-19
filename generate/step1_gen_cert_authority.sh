# this runs inside the Open SSL Docker container
# /export is mounted to $PWD

set -e
CERT_DIR=/export/keys/ca
PASSWORD=foobar5150
COMMON_NAME=ca.codetojoy.net

#################
# 1.1 : generate private key

openssl genrsa -aes256 -passout pass:"${PASSWORD}" \-out $CERT_DIR/ca_key.pem 4096

stat $CERT_DIR/ca_key.pem > /dev/null 2>&1

#################
# 1.2 : generate public key that points to private key (expiry is 365 days)

openssl req -new -passin pass:"${PASSWORD}" -key $CERT_DIR/ca_key.pem \
-x509 -days 365 -out $CERT_DIR/ca_cert.pem -subj "/CN=${COMMON_NAME}"

stat $CERT_DIR/ca_key.pem > /dev/null 2>&1

