#!/bin/bash

fatalln() {
    echo $*
    exit 1
}

[ ! -f $1 ] && fatalln No config file

source $1

job=$2
xml=$3

curl -X POST "http://${user}:${password}@${url}/createItem?name=${job}" --data-binary "@${xml}" -H "Content-Type: text/xml"
