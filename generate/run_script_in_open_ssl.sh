#!/bin/bash

docker run -v $(pwd):/export prabath/openssl /export/steps_full.sh

