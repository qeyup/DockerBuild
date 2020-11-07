#!/bin/bash

export ENTRYPOINT_EXPORT_2a="@{BUILD_EXPORT_1}"

for ((i=0;;i++)); do
    echo $i > /tmp/secs
    sleep 1
done
