#!/bin/bash
set -e



#~~~ CONFIGURABLE PARAMETERS ~~~~~~~~~~~~~~
#> base image
DOCKER_BASE_IMAGE="ubuntu:18.04"

#> base image
DOCKER_IMAGE_NAME="docker_image_name"

# Added args when building de image
DOCKER_BUILD_ARGS=""

# Added lines at the top of the generated Dockerfile
DOCKER_HEADER_FILE=""

# Added lines at the buttom of the generated Dockerfile
DOCKER_TAIL_FILE=""

# Skip similar bash files (true/false)
SKIP=true

# File to find and execute
EXEC="Dockerfile.sh"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


##########################################
#> Tmp dir
TMP_DIR=".added/"
TMP_DOCKER_FOLDER="/tmp/docker_build"
SORT_STRING="zzzzzzzzzzzzzzzzzzzzzzzzzzzz"
rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}


#> Create main docker file
rm -f Dockerfile
touch Dockerfile
echo "FROM ${DOCKER_BASE_IMAGE}" >> Dockerfile
echo "" >> Dockerfile
echo "" >> Dockerfile

#> Add header file
if [ -f "${DOCKER_HEADER_FILE}" ]
then
    cat ${DOCKER_HEADER_FILE} >> Dockerfile
    echo "" >> Dockerfile
    echo "" >> Dockerfile
fi

#> Find build scripts
find $PWD -name "$EXEC" | sed "s/$EXEC/$SORT_STRING/g" | sort | sed "s/$SORT_STRING/$EXEC/g" | while read file
do
    #> Check
    if [ "$SKIP" = true ] ; then
        #> Generate tmp file
        CHECK=$(md5sum "${file}" | cut -c -32)
        CHECK="${TMP_DIR}/${CHECK}"


        #> Check if file is been executed
        if [ -e "${CHECK}" ]
        then
            echo "[SKIPED] ${file}"
            continue
        fi
    fi


    #> Exec install
    SOURCE_DIR=$(dirname "$file")
    SOURCE_DIR=$(realpath --relative-to=$PWD $SOURCE_DIR)
    echo "# Building '${SOURCE_DIR}/${EXEC}'" >> Dockerfile
    echo "RUN mkdir -p ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}" >> Dockerfile
    echo "COPY ${SOURCE_DIR}/. ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}/" >> Dockerfile
    echo "RUN chmod u+x ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}/${EXEC}" >> Dockerfile
    echo "RUN cd ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}/ && /bin/bash -iex -c \"source ${EXEC}\"" >> Dockerfile
    echo "" >> Dockerfile
    echo "" >> Dockerfile


    #> Register
    echo "[ADDED]  ${file}"
    if [ "$SKIP" = true ] ; then
        touch "${CHECK}"
    fi
done


#> Clean
echo "RUN rm -rf ${TMP_DOCKER_FOLDER}" >> Dockerfile


#> Add tail
if [ -f "${DOCKER_HEADER_FILE}" ]
then
    cat ${DOCKER_HEADER_FILE} >> Dockerfile
    echo "" >> Dockerfile
    echo "" >> Dockerfile
fi


# Execute docker build
(
    set -x
    sudo docker build -t $DOCKER_IMAGE_NAME $DOCKER_BUILD_ARGS .
)


# Remove temporal files
rm -r ${TMP_DIR}
#rm Dockerfile