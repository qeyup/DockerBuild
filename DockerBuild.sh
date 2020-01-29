#!/bin/bash
set -e


#> Log
function log {
    echo -e "$@"
}

#> Variables
TMP_DOCKER_FOLDER="/tmp/docker_build"
SORT_STRING="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
EXEC="Dockerfile.sh"
EXEC_DEBUG="Dockerfile.debug.sh"
EXEC_SORT_KEY="Dockerfile."
CREATED_DOCKER_FILE=".Dockerfile"
GENERATE_CONTENT_LABEL="# [DO NOT REMOVE THIS LINE. THIS LINE WILL BE REMPLACED WITH GENERATED CODE]"
DEFAULT_DOCKERFILE_PATH="$PWD"
DOCKER_DEBUG_FOLDER="/tmp/debug_folder"
DOCKER_DEBUG_SCRIPT="/tmp/debug.sh"
DOCKER_WORKSPACE="/root/"


# Process args
while getopts hd:D:a opt
do
    case $opt in
        # Help
        h)
            log "The script will search for 'Dockerfile.sh' scripts and append them in the main Dockerfile before build it."
            log "* It will take into acount the found 'Dockerfile.sh' files hierarchy order."
            log "* To debug an 'Dockerfile.sh' script just set the script name as 'Dockerfile.debug.sh'."
            log ""
            log ""
            log " DockerBuild.sh comand args help"
            log ""
            log "  -D \t Folder where Dockerfile is place. By default is the calling directory."
            log "  -d \t Folder where script will start the search of 'dockerfile.sh' files. This path can't be lower than the Dockerfile folder. By default is the Dockerfile folder."
            log "  -a \t docker build command args."
            log ""
            log ""
            log "   Docker build command args help"
            log ""
            docker build --help 2> /dev/null | grep "  -*" | grep -v "  -t,"
            log ""
            log ""
            exit 0
        ;;

        d)
            DOCKERFILE_SCRIPTS_START_SEARCH="$OPTARG"
            if [ ! -d "$DOCKERFILE_SCRIPTS_START_SEARCH" ]
            then
                log "Given dir path '$DOCKERFILE_SCRIPTS_START_SEARCH' does not exists"
                exit -1
            fi
        ;;

        D)
            DOCKERFILE_PATH="$OPTARG"
            if [ ! -d "$DOCKERFILE_PATH" ]
            then
                log "Given dir path '$DOCKERFILE_PATH' does not exists"
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


#> Set defaults
if [ "$DOCKERFILE_PATH" = "" ]
then
    DOCKERFILE_PATH="$DEFAULT_DOCKERFILE_PATH"
fi
if [ "$DOCKERFILE_SCRIPTS_START_SEARCH" = "" ]
then
    DOCKERFILE_SCRIPTS_START_SEARCH="$DOCKERFILE_PATH"
fi


#> Set Dockerfile path
DOCKERFILE_SCRIPTS_START_SEARCH=$(realpath "$DOCKERFILE_SCRIPTS_START_SEARCH" --relative-to "$DOCKERFILE_PATH")
cd "$DOCKERFILE_PATH"
DOCKERFILE_PATH="Dockerfile"


#> Chech script path
echo "$DOCKERFILE_SCRIPTS_START_SEARCH"
if [ ! -d "$(echo "$DOCKERFILE_SCRIPTS_START_SEARCH" | sed s/'\.\.'/NOT_VALID/g)" ]
then
    log "Given dir path '$DOCKERFILE_SCRIPTS_START_SEARCH' is not valid"
    exit -1
fi


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
    DOCKERFILE_CONTEND+="########################################\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="$GENERATE_CONTENT_LABEL"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="WORKDIR /root/\n"
    DOCKERFILE_CONTEND+="\n"

    echo -e "$DOCKERFILE_CONTEND" > "$DOCKERFILE_PATH"
    log "Created template Dokerfile. Configure it and execute again '$0 $@' to build de docker image."
    exit 0
fi


# Read variables
VARS_ARRAY=$(cat "$DOCKERFILE_PATH" | grep "#DB " | sed "s/^#DB //g" | while read var; do echo $var; done; )

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


#> Create main docker file
rm -f ${CREATED_DOCKER_FILE}
touch ${CREATED_DOCKER_FILE}


#> Find files and sort them
IFS=";"
FOUND_FILES=$(find $DOCKERFILE_SCRIPTS_START_SEARCH -name "$EXEC" -or -name "$EXEC_DEBUG" | sed "s/$EXEC_SORT_KEY/$SORT_STRING/g" | sort | sed "s/$SORT_STRING/$EXEC_SORT_KEY/g" | while read file; do echo -ne "${file};"; done;)


#> Find build scripts
counter=0
for file in $FOUND_FILES
do
    #> Check debug
    if [ "$(basename ${file})" == "$EXEC_DEBUG" ]
    then
        log "[DEBUG]  ${file}"
        DEBUG_FOLDER=$(realpath $(dirname "$file"))
        DOCKERFILE_CONTEND+="RUN echo \"#!/bin/bash\" >> ${DOCKER_DEBUG_SCRIPT} \n"
        DOCKERFILE_CONTEND+="RUN echo \"find ${DOCKER_DEBUG_FOLDER} -maxdepth 1 -mindepth 1 -exec  ln -s {} ${DOCKER_WORKSPACE} \\;\" >> ${DOCKER_DEBUG_SCRIPT}\n"
        DOCKERFILE_CONTEND+="RUN chmod u+x \"${DOCKER_DEBUG_SCRIPT}\"\n"
        DOCKERFILE_CONTEND+="ENTRYPOINT ${DOCKER_DEBUG_SCRIPT} && rm ${DOCKER_DEBUG_SCRIPT} && bash \n"
        break
    fi


    #> Exec install steps
    counter=$((counter+1))
    SOURCE_DIR=$(dirname "$file")
    SOURCE_DIR=$(realpath --relative-to=$PWD "$SOURCE_DIR")
    DOCKERFILE_CONTEND+="# Building '${SOURCE_DIR}/${EXEC}'\n"
    DOCKERFILE_CONTEND+="RUN mkdir -p \"${TMP_DOCKER_FOLDER}/${counter}\"\n"
    DOCKERFILE_CONTEND+="COPY [\"${SOURCE_DIR}/.\", \"${TMP_DOCKER_FOLDER}/${counter}/\"]\n"
    DOCKERFILE_CONTEND+="RUN chmod u+x \"${TMP_DOCKER_FOLDER}/${counter}/${EXEC}\"\n"
    DOCKERFILE_CONTEND+="RUN cd \"${TMP_DOCKER_FOLDER}/${counter}/\" && /bin/bash -iex -c \"source ${EXEC}\"\n"
    DOCKERFILE_CONTEND+="\n"
    DOCKERFILE_CONTEND+="\n"


    #> Register
    log "[ADDED]  ${file}"
done


#> Clean step
DOCKERFILE_CONTEND+="RUN rm -rf \"${TMP_DOCKER_FOLDER}\""


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


#> root command required
if [ "$EUID" -ne 0 ]
then
    ROOT_COMMAND="sudo"
fi

#> Execute docker build
(
    log ""
    set -x
    bash -c "$ROOT_COMMAND docker build -t $DOCKER_IMAGE_NAME -f ${CREATED_DOCKER_FILE} ${DOCKER_BUILD_ARGS} ${DOCKER_BUILD_EXTRA_ARGS} ."
)


#> Start debug session
if [ ! "$DEBUG_FOLDER" = "" ]
then
    (
        log ""
        set -x
        $ROOT_COMMAND docker run \
                                -it \
                                --rm \
                                --name ${DOCKER_IMAGE_NAME}_debug \
                                -v ${DEBUG_FOLDER}:${DOCKER_DEBUG_FOLDER} \
                                -w ${DOCKER_WORKSPACE} \
                                ${DOCKER_IMAGE_NAME}
    )
fi


#> Remove temporal files
rm ${CREATED_DOCKER_FILE}