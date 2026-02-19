#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

GOFLAGS="${GOFLAGS:-}"

# Test if the go compiler supports GOEXPERIMENT=strictfipsruntime by building a minimal program.
# Using ./tools doesn't work as it contains only tool dependency imports that aren't buildable.
fips_test_file=$(mktemp --suffix=.go)
trap 'rm -f ${fips_test_file}' EXIT
echo 'package main; func main(){}' > "${fips_test_file}"

if GOEXPERIMENT="strictfipsruntime" go build -o /dev/null "${fips_test_file}" > /dev/null 2>&1 ; then
    echo "INFO: building with FIPS support"

    export GOEXPERIMENT="strictfipsruntime"
    export GOFLAGS="${GOFLAGS} -tags=strictfipsruntime,openssl"
else
    echo "WARN: building without FIPS support, GOEXPERIMENT strictfipsruntime is not available in the go compiler"
    echo "WARN: this build cannot be used in CI or production, due to lack of FIPS!!"
fi
