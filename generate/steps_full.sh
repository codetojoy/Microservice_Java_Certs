# this runs inside the Open SSL Docker container
# /export is mounted to $PWD

set -e

mkdir -p /export/keys/ca
mkdir -p /export/keys/orderprocessing
mkdir -p /export/keys/inventory

/export/step1_gen_cert_authority.sh 

/export/step2_gen_keys.sh 

echo "RESULT:"
find /export/keys

