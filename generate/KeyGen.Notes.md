
* from Appendix G in ms book 
* use inside Docker container
    - uses prabath/openssl image
    - unclear if `jks` and `p12` files are necessary? 

### generate Cert Authority

* 1.1
* generate private key
* output: ~/ca/ca_key.pem
 
```
openssl genrsa -aes256 -passout pass:"manning123" \-out /export/ca/ca_key.pem 4096
```

* 1.2
* generate public key that points to private key
* expiry is 365 days
* output: ~/ca/ca_cert.pem

```
openssl req -new -passin pass:"manning123" -key /export/ca/ca_key.pem \
-x509 -days 365 -out /export/ca/ca_cert.pem -subj "/CN=ca.ecomm.com"
```

### generate Cert

* 2.1
* generate private key for app, using CA above
* output: ~/application/app_key.pem

```
openssl genrsa -aes256 -passout pass:"manning123" \
-out /export/application/app_key.pem 4096
```

* 2.2
* generate cert-signing request (CSR)
* this is request to get private key from 2.1 signed by CA
* output: ~/application/csr-for-app

```
openssl req -passin pass:"manning123" -new \
-key /export/application/app_key.pem -out /export/application/csr-for-app \
-subj "/CN=app.ecomm.com"
```

* 2.3
* generate signed certificate
* output: ~/application/app_cert.pem

```
openssl x509 -req -passin pass:"manning123" \
-days 365 -in /export/application/csr-for-app \
-CA /export/ca/ca_cert.pem -CAkey /export/ca/ca_key.pem \
-set_serial 01 -out /export/application/app_cert.pem
```

* 2.4
* we now have private key and signed cert for app 
* use these to generate JKS for Spring Boot app
* output: in ~/application: app.p12 app.jks

* remove passphrase of private key 
```
openssl rsa -passin pass:"manning123" \
-in /export/application/app_key.pem -out /export/application/app_key.pem
```

* create single file (application_keys.pem) with private key and public cert
```
cat /export/application/app_key.pem /export/application/app_cert.pem \
>> /export/application/application_keys.pem
```

* create PKCS file
```
openssl pkcs12  -export -passout pass:"manning123" \
-in /export/application/application_keys.pem -out /export/application/app.p12
```

* create JKS file
```
keytool -importkeystore -srcstorepass manning123 \
-srckeystore /export/application/app.p12 -srcstoretype pkcs12 \
-deststorepass manning123 -destkeystore /export/application/app.jks \
-deststoretype JKS       
```
