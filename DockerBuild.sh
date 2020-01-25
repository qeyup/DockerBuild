#!/bin/bash
set -e


#> Log
function log {
    echo -e "$@"
}

#> Variables
TMP_DIR=".added/"
TMP_DOCKER_FOLDER="/tmp/docker_build"
SORT_STRING="zzzzzzzzzzzzzzzzzzzzzzzzzzzz"
EXEC="Dockerfile.sh"
CREATED_DOCKER_FILE=".Dockerfile"
GENERATE_CONTENT_LABEL="# [GENERATED CONTENT SPACE (DO NOT REMOVE THIS LINE)]"
DOCKERFILE_SCRIPTS_START_SEARCH="$PWD"


# Process args
while getopts hd:a opt
do
    case $opt in
        # Help
        h)
            log ""
            log "DockerBuild.sh comand args help"
            log ""
            log "  -d \t Dir where start the searh of dockerfile.sh files. By defaukt is '$PWD'"
            log "  -a \t Specify docker build command args"
            log ""
            log ""
            log "  Docker build command args help"
            log ""
            docker build --help 2> /dev/null | grep "  -*" | grep -v "  -t,"
            log ""
            log ""
            exit 0
        ;;

        d)
            DOCKERFILE_SCRIPTS_START_SEARCH=$(realpath $OPTARG --relative-to $PWD)
            if [ -d "$(echo $DOCKERFILE_SCRIPTS_START_SEARCH | sed s/'\/..'/NOT_VALID/g)" ]
            then
                log "Dockerfile.sh search will start at '$DOCKERFILE_SCRIPTS_START_SEARCH' "
            else
                log "Given dir path '$DOCKERFILE_SCRIPTS_START_SEARCH' is not valid"
                exit -1
            fi
        ;;

        a) 
            shift $(($OPTIND - 1))
            DOCKER_BUILD_EXTRA_ARGS="$@"
            break
        ;;

      
    esac
done


#> Set Dockerfile path
DOCKERFILE_PATH="$PWD/Dockerfile"


# Create Dockerfile template
if [ ! -f "$DOCKERFILE_PATH" ]
then
    DOCKERFILE_CONTEND=""
    DOCKERFILE_CONTEND+="FROM ubuntu:18.04\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="########################################\n"
    DOCKERFILE_CONTEND+="# Docker image name\n"
    DOCKERFILE_CONTEND+="#DB DOCKER_IMAGE_NAME=docker_image_name\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="# Docker build defined args\n"
    DOCKERFILE_CONTEND+="#DB DOCKER_BUILD_ARGS=\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="# Skip similar found modules\n"
    DOCKERFILE_CONTEND+="#DB SKIP=true\n"
    DOCKERFILE_CONTEND+="########################################\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="$GENERATE_CONTENT_LABEL"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="WORKDIR /root/\n"
    DOCKERFILE_CONTEND+="\n"

    echo -e "$DOCKERFILE_CONTEND" > $DOCKERFILE_PATH
    log "Created template Dokerfile. Configure it and execute again '$0$@' to build de docker image."
    exit 0
fi


# Read variables
VARS_ARRAY=$(cat $DOCKERFILE_PATH | grep "#DB " | sed "s/^#DB //g" | while read var; do echo $var; done; )

# export vars
for VAR in $VARS_ARRAY
do
    export $VAR
done


# Check 
if [ "$DOCKER_IMAGE_NAME" = "" ]
then
    log "DOCKER_IMAGE_NAME valiable is missing"
    exit -1
fi


#> Tmp dir
rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}


#> Create main docker file
rm -f ${CREATED_DOCKER_FILE}
touch ${CREATED_DOCKER_FILE}


#> Find files and sort them
FOUND_FILES=$(find $DOCKERFILE_SCRIPTS_START_SEARCH -name "$EXEC" | sed "s/$EXEC/$SORT_STRING/g" | sort | sed "s/$SORT_STRING/$EXEC/g" | while read file; do echo ${file}; done;)


#> Find build scripts
for file in $FOUND_FILES
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


    #> Exec install steps
    SOURCE_DIR=$(dirname "$file")
    SOURCE_DIR=$(realpath --relative-to=$PWD $SOURCE_DIR)
    DOCKERFILE_CONTEND+="# Building '${SOURCE_DIR}/${EXEC}'\n"
    DOCKERFILE_CONTEND+="RUN mkdir -p ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}\n"
    DOCKERFILE_CONTEND+="COPY ${SOURCE_DIR}/. ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}/\n"
    DOCKERFILE_CONTEND+="RUN chmod u+x ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}/${EXEC}\n"
    DOCKERFILE_CONTEND+="RUN cd ${TMP_DOCKER_FOLDER}/${SOURCE_DIR}/ && /bin/bash -iex -c \"source ${EXEC}\"\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="\n"


    #> Register
    echo "[ADDED]  ${file}"
    if [ "$SKIP" = true ] ; then
        touch "${CHECK}"
    fi
done


#> Clean step
DOCKERFILE_CONTEND+="RUN rm -rf ${TMP_DOCKER_FOLDER}"


#> Put generated code in file
cat $DOCKERFILE_PATH | while read LINE
do
    if [ "$LINE" = "${GENERATE_CONTENT_LABEL}" ]
    then
        echo -e "${DOCKERFILE_CONTEND}" >> ${CREATED_DOCKER_FILE}
        DOCKERFILE_CONTEND=""
    else
        echo -e "${LINE}" >> ${CREATED_DOCKER_FILE}
    fi
done


# Execute docker build
(
    if [ "$EUID" -ne 0 ]
    then
        set -x
        sudo docker build -t $DOCKER_IMAGE_NAME -f ${CREATED_DOCKER_FILE} $DOCKER_BUILD_ARGS $DOCKER_BUILD_EXTRA_ARGS .
    else
        set -x
        docker build -t $DOCKER_IMAGE_NAME -f ${CREATED_DOCKER_FILE} $DOCKER_BUILD_ARGS $DOCKER_BUILD_EXTRA_ARGS .
    fi
)


# Remove temporal files
rm -r ${TMP_DIR}
rm ${CREATED_DOCKER_FILE}