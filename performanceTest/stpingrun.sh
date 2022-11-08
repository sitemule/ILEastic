#!/bin/bash
## test parameters:
let sessions=10
let repeat=10000
let sleep=1

echo "Start test"
let counter=1
while test $counter -le $sessions ; do
    ##./pingrun.sh $sessions &
    node pingnode.js $repeat $counter $sleep &
    let counter=$counter+1
done
