#!/bin/bash
set -e

# Tmp dir
export TMP_DIR="/tmp/Dockerinstall"
export EXEC="Dockerfile.sh"
export SORT_STRING="~~~~~~~~"
mkdir -p $TMP_DIR


# Find all install script
find $PWD -name "$EXEC" | sed "s/$EXEC/$SORT_STRING/g" | sort | sed "s/$SORT_STRING/$EXEC/g" | while read file
do
    # Generate tmp file
    CHECK=$(md5sum "$file" | cut -c -32)
    CHECK="$TMP_DIR/$CHECK"


    # Check if file is been executed
    SEP="============================================================================"
    if [ -e "$CHECK" ]
    then
        echo "$SEP"
        echo "[SKIPED] $file"
        echo "$SEP"
        continue
    else
        echo "$SEP"
        echo "[BUILDING] $file"
        echo "$SEP"
        touch "$CHECK"
    fi

    # Execute
    (
        # Exec istall
        SOURCE_DIR=$(dirname "$file")
        cd "$SOURCE_DIR"
        chmod +x $EXEC
        /bin/bash -exi -c "source $EXEC" || ( echo "$SEP" && echo "[ERROR] $file" && echo "$SEP" &&  exit -1; )
    )

    echo "$SEP"
    echo "[BUILT] $file"
    echo "$SEP"

done


# Remove temporal files
rm -rf $TMP_DIR