
### Usage

* type 1:
    - `./run_open_ssh.sh`
    - inside Docker container: `/export/steps_full.sh`
* type 2:
    - `./run_script_in_open_ssl.sh`

### Notes 

* keys/ca:
    - ca == cert authority
    - public key: ca_cert.pem
    - private key: ca_key.pem
* keys/orderprocessing:
    - JKS file
    - ca_cert.pem (public key for CA)
    - its own public/private key pair 
* keys/inventory:
    - JKS file
    - ca_cert.pem (public key for CA)
    - its own public/private key pair 

### Misc Notes

* these file formats are called 'containers' ?
* `pem` 
    - can store cert or cert chains
    - originally "Privacy Enhanced Mail" but that is no longer applicable 
    - defined in RFC 1421 - 1424 
    - base64, not encrypted
* `p12`
    - fully encrypted
    - PKCS: Public-Key Crypto Standards
    - '12' introduced by Microsoft and later standardized 
    - contains both public/private
    - possibly synomynous with `pkcs12` ?
* `jks`
    - encrypted, password protected
    - stores set of crypto keys or certs 

### Resources

* https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file
* https://stackoverflow.com/a/45886431/12704
* https://fileinfo.com/extension/jks#:~:text=A%20JKS%20file%20is%20an,a%20password%20to%20be%20opened.&text=Because%20JKS%20files%20contain%20sensitive,are%20encrypted%20and%20password%2Dprotected.
