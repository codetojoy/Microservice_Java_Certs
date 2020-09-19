# this runs inside the Open SSL Docker container
# /export is mounted to $PWD

set -e

/export/key_gen_for_app_param.sh orderprocessing
/export/key_gen_for_app_param.sh inventory

