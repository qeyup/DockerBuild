#!/bin/bash
set -e

# Tmp dir
export TMP_DIR="/tmp/Dockerinstall"
export EXEC="Dockerfile.sh"
mkdir -p $TMP_DIR


# Find all install script
find $PWD -name "$EXEC" | while read line; do echo "$(echo $line | grep -o / | wc -l)->$line"; done | sort -rn | while read file
do
    # Remove num
    file=$(echo $file | sed "s/^.*->//g")

    # Generate tmp file
    CHECK=$(md5sum "$file" | cut -c -32)
    CHECK="$TMP_DIR/$CHECK"


    # Check if file is been executed
    if [ -e "$CHECK" ]
    then
        continue
    else
        touch "$CHECK"
    fi


    # Execute
    (
        # Reload variables
        . /etc/bash.bashrc
        . ~/.bashrc

        # Exec istall
        SOURCE_DIR=$(dirname "$file")
        cd "$SOURCE_DIR"
        chmod +x $EXEC
        . $EXEC
    )

done


# Remove temporal files
rm -rf $TMP_DIR
