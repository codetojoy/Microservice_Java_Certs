# this runs inside the Open SSL Docker container
# /export is mounted to $PWD

set -e 

# e.g. APP_DIR=orderprocessing
APP=$1
APP_DIR=$APP
ALIAS=$APP
APP_JKS="${APP}".jks
OUTPUT_DIR=/export/keys/$APP_DIR

CERT_DIR=/export/keys/ca
PASSWORD=foobar5150
COMMON_NAME=ca.codetojoy.net

#################
# 2.1 :   generate private key for app
# output: ~/$OUTPUT_DIR/app_key.pem

openssl genrsa -aes256 -passout pass:"${PASSWORD}" -out $OUTPUT_DIR/app_key.pem 4096

stat $OUTPUT_DIR/app_key.pem > /dev/null 2>&1

#################
# 2.2 : generate cert-signing request (CSR)
# this is request to get private key from 2.1 signed by CA
# output: ~/$OUTPUT_DIR/csr-for-app

openssl req -passin pass:"${PASSWORD}" -new \
-key $OUTPUT_DIR/app_key.pem -out $OUTPUT_DIR/csr-for-app -subj "/CN=${COMMON_NAME}"

stat $OUTPUT_DIR/csr-for-app > /dev/null 2>&1

#################
# 2.3 : generate signed certificate
# output: ~/application/app_cert.pem

openssl x509 -req -passin pass:"${PASSWORD}" \
-days 365 -in $OUTPUT_DIR/csr-for-app \
-CA $CERT_DIR/ca_cert.pem -CAkey $CERT_DIR/ca_key.pem \
-set_serial 01 -out $OUTPUT_DIR/app_cert.pem

stat $OUTPUT_DIR/app_cert.pem > /dev/null 2>&1

#################
# 2.4 : we now have private key and signed cert for app 
# use these to generate JKS for Spring Boot app
# output: in ~/application: app.p12 ${APP_JKS}

# remove passphrase of private key 
openssl rsa -passin pass:"$PASSWORD" \
-in $OUTPUT_DIR/app_key.pem -out $OUTPUT_DIR/app_key.pem

# create single file (application_keys.pem) with private key and public cert
cat $OUTPUT_DIR/app_key.pem $OUTPUT_DIR/app_cert.pem >> $OUTPUT_DIR/application_keys.pem

stat $OUTPUT_DIR/application_keys.pem > /dev/null 2>&1

# create PKCS file
openssl pkcs12  -export -passout pass:"${PASSWORD}" \
-in $OUTPUT_DIR/application_keys.pem -out $OUTPUT_DIR/app.p12

stat $OUTPUT_DIR/app.p12 > /dev/null 2>&1

# create JKS file
keytool -importkeystore -srcstorepass $PASSWORD \
-srckeystore $OUTPUT_DIR/app.p12 -srcstoretype pkcs12 \
-deststorepass $PASSWORD -destkeystore $OUTPUT_DIR/${APP_JKS} \
-deststoretype JKS       

TMP_RESULT=$?
echo "TRACER cp 1 result: ${TMP_RESULT}"
stat $OUTPUT_DIR/${APP_JKS} > /dev/null 2>&1

keytool -changealias -alias "1" -destalias "${ALIAS}" -keystore $OUTPUT_DIR/$APP_JKS -storepass $PASSWORD

TMP_RESULT=$?
echo "TRACER cp 2 result: ${TMP_RESULT}"

keytool -import -file $CERT_DIR/ca_cert.pem -alias ca -noprompt -keystore $OUTPUT_DIR/$APP_JKS -storepass $PASSWORD

TMP_RESULT=$?
echo "TRACER cp 3 result: ${TMP_RESULT}"

# remove transient files
rm $OUTPUT_DIR/app.p12 
rm $OUTPUT_DIR/application_keys.pem 
rm $OUTPUT_DIR/app_cert.pem 
rm $OUTPUT_DIR/app_key.pem
rm $OUTPUT_DIR/csr-for-app

