#!/bin/bash

fatalln() {
    echo $*
    exit 1
}

[ -z $1 ] && fatalln Instance name needed

instance=$1

[ ! -d ${instance} ] && fatalln Directory does not exist

# Some sanity check
if [[ ${instance} =~ ^/ ]]; then fatalln Path must be relative; fi

rm -rf ${instance} ${instance}.env
docker rm -f ${instance} >/dev/null

echo ${instance} removed
