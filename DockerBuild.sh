#!/bin/bash
set -e


#> Log
function log {
    echo -e "$@"
}

#> Variables
TMP_DOCKER_FOLDER="/tmp/docker_build"
SORT_STRING="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

CREATED_DOCKER_FILE=".GeneratedBuildFile"
DOKERFILE_APPEND="DockerfileAppend"
EXEC="Dockerfile.sh"
EXEC_DEBUG="Dockerfile.debug.sh"
BUILD_EXPORT_SOURCE="BuildExport.source"
IMAGE_EXPORT_SOURCE="ImageExport.source"

GENERATE_CONTENT_LABEL="# [DO NOT REMOVE THIS LINE. THIS LINE WILL BE REMPLACED WITH GENERATED CODE]"
DEFAULT_DOCKERFILE_PATH="$PWD"
DOCKER_DEBUG_FOLDER="/tmp/debug_folder"
DOCKER_WORKSPACE="/root/workspace"
BUILD_SOURCE_FILE=${TMP_DOCKER_FOLDER}/dockerBuild.source
IMAGE_SOURCE_FILE=${TMP_DOCKER_FOLDER}/bash.bashrc


# Process args
while getopts fkhd:D:a opt
do
    case $opt in
        # Help
        h)
            log "DockerBuild script is meant to help the docker build process. Is just a wrapper of the docker build process."
            log "It will search for '${EXEC}', '${BUILD_EXPORT_SOURCE}', '${IMAGE_EXPORT_SOURCE}' and '${DOKERFILE_APPEND}' files/files extensions and add them to the docker image build steps sorting them by name and nesting level position."
            log ""
            log ""
            log "File extensions description"
            log "  * ${EXEC}: shell script that will be executed in a docker build step. In order to debug it, change the file extension to '.${EXEC_DEBUG}'."
            log "  * ${BUILD_EXPORT_SOURCE}: Source file that will be included only in the build process."
            log "  * ${IMAGE_EXPORT_SOURCE}: Source file that will be included to the docker container execution and build process."
            log "  * ${DOKERFILE_APPEND}: Append dockerfile raw layers."
            log ""
            log ""
            log " DockerBuild.sh comand args help"
            log ""
            log "  -D \t Folder where Dockerfile is place. By default is the calling directory."
            log "  -d \t Folder where script will start the search. This path can't be lower than the Dockerfile folder. By default is the Dockerfile folder."
            log "  -k \t Don't remove temporal files."
            log "  -f \t Only display script build order."
            log "  -a \t 'docker build' command args."
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

        k)
            KEEP_TMP_FILES=1
        ;;

        f)
            ONLY_DISPLAY_FILE_ORDER=1
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


#> Make docker build folder and create an empy build source file
DOCKERFILE_CONTEND+="# Make docker build folder and create an empy build source file\n"
DOCKERFILE_CONTEND+="RUN mkdir -p \"${TMP_DOCKER_FOLDER}/\" && \\ \n"
DOCKERFILE_CONTEND+="touch \"${BUILD_SOURCE_FILE}\" && \\ \n"
DOCKERFILE_CONTEND+="touch \"${IMAGE_SOURCE_FILE}\" && \\ \n"
DOCKERFILE_CONTEND+="/bin/bash -c \"echo\" >> /etc/bash.bashrc \n"
DOCKERFILE_CONTEND+="\n"
DOCKERFILE_CONTEND+="\n"


#> Find files and sort them
IFS=";"
FOUND_FILES=$(find ${DOCKERFILE_SCRIPTS_START_SEARCH} -type f -name "*${EXEC}" \
                                                          -or -name "*${EXEC_DEBUG}" \
                                                          -or -name "*${IMAGE_EXPORT_SOURCE}" \
                                                          -or -name "*${BUILD_EXPORT_SOURCE}" \
                                                          -or -name "*${DOKERFILE_APPEND}" \
                                                            | sed -E "s/([^/]+*${EXEC}$)/${SORT_STRING}\1/g" \
                                                            | sed -E "s/([^/]+*${EXEC_DEBUG}$)/${SORT_STRING}\1/g" \
                                                            | sed -E "s/([^/]+*${BUILD_EXPORT_SOURCE}$)/${SORT_STRING}\1/g" \
                                                            | sed -E "s/([^/]+*${IMAGE_EXPORT_SOURCE}$)/${SORT_STRING}\1/g" \
                                                            | sed -E "s/([^/]+*${DOKERFILE}$)/${SORT_STRING}\1/g" \
                                                            | sed -E "s/([^/]+*${DOKERFILE_APPEND}$)/${SORT_STRING}\1/g" \
                                                            | sort \
                                                            | sed "s/${SORT_STRING}//g" \
                                                            | while read file; do echo -ne "${file};"; done;)


#> Find build scripts
counter=0
for file in ${FOUND_FILES}
do

    # Get file name
    FILE_NAME="$(basename $file)"


    #> Get work dir
    SOURCE_DIR=$(dirname "${file}")
    SOURCE_DIR=$(realpath --relative-to=${PWD} "${SOURCE_DIR}")
    if  [ ! "${SOURCE_DIR}" = "${LAST_SOURCE_DIR}" ]
    then
        LAST_SOURCE_DIR=$SOURCE_DIR
        counter=$((counter+1))
        DOCKERFILE_CONTEND+="# Copy source files '${SOURCE_DIR}'\n"
        DOCKERFILE_CONTEND+="RUN mkdir -p \"${TMP_DOCKER_FOLDER}/${counter}\"\n"
        DOCKERFILE_CONTEND+="COPY [\"${SOURCE_DIR}/.\", \"${TMP_DOCKER_FOLDER}/${counter}/\"]\n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"
    fi


    #> Check debug
    if [ "$(echo $(basename ${file}) | grep ${EXEC_DEBUG})" != "" ]
    then
        DEBUG_FOLDER=$(realpath $(dirname "$file"))
        DOCKERFILE_CONTEND+="RUN cat ${BUILD_SOURCE_FILE} >> /etc/bash.bashrc\n"
        DOCKERFILE_CONTEND+="ENTRYPOINT cp -r ${DOCKER_DEBUG_FOLDER}/* ${DOCKER_WORKSPACE}/ && ln -sf '${DOCKER_DEBUG_FOLDER}/${FILE_NAME}' '${DOCKER_WORKSPACE}/${FILE_NAME}' && bash \n"

        log "[ DOCKERFILE DEBUG STEP   ]  ${file}"

        break


    elif [ "$(echo $(basename ${file}) | grep ${EXEC})" != "" ]
    then
        #> Exec install steps
        DOCKERFILE_CONTEND+="# Building '${SOURCE_DIR}/${FILE_NAME}'\n"
        DOCKERFILE_CONTEND+="RUN echo \"\033[1;32m> Building '${SOURCE_DIR}/${FILE_NAME}'...\033[0m\" && \\ \n"
        DOCKERFILE_CONTEND+="chmod u+x \"${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}\" && \\ \n"
        DOCKERFILE_CONTEND+="cd \"${TMP_DOCKER_FOLDER}/${counter}/\" && /bin/bash -c \"source ${BUILD_SOURCE_FILE} && source ${IMAGE_SOURCE_FILE} && (set -xe; . './${FILE_NAME}'); RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${FILE_NAME}'\033[0m\\\"; exit -1; fi \" && \\ \n"
        DOCKERFILE_CONTEND+="echo \"\033[1;32m> Done!\033[0m\" && \\ \n"
        DOCKERFILE_CONTEND+="echo #DO_NOT_PRINT \n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[ \033[1;32mDOCKERFILE STEP ADDED\033[0m   ]  ${file}"

    elif [ "$(echo $(basename ${file}) | grep ${BUILD_EXPORT_SOURCE})" != "" ]
    then
        #> Add source to source file
        DOCKERFILE_CONTEND+="# Append build source file '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\n"
        DOCKERFILE_CONTEND+="RUN echo \"\033[1;34m> Adding source '${SOURCE_DIR}/${FILE_NAME}'...\033[0m\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"echo '# Source from ${SOURCE_DIR}/${FILE_NAME}' \" >> ${BUILD_SOURCE_FILE} && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"source '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'; RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${FILE_NAME}'\033[0m\\\"; exit -1; fi \" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"cat '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\" >> ${BUILD_SOURCE_FILE} && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"echo \" >> ${BUILD_SOURCE_FILE} && \\ \n"
        DOCKERFILE_CONTEND+="echo \"\033[1;34m> Done!\033[0m\" && \\ \n"
        DOCKERFILE_CONTEND+="echo #DO_NOT_PRINT \n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[ \033[1;34mBUILD SOURCE ADDED\033[0m      ]  ${file}"

    elif [ "$(echo $(basename ${file}) | grep ${IMAGE_EXPORT_SOURCE})" != "" ]
    then
        #> Add source to source file and to bash rc file
        DOCKERFILE_CONTEND+="# Append image source file '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\n"
        DOCKERFILE_CONTEND+="RUN echo \"\033[1;35m> Adding source '${SOURCE_DIR}/${FILE_NAME}'...\033[0m\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"echo '# Source from ${SOURCE_DIR}/${FILE_NAME}' \" >> ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i 's/\\\"/%%%%%%%%%%quot##########/g' '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i \\\"s/'/%%%%%%%%%%apos##########/g\\\" '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i \\\"s/[\\\$]/%%%%%%%%%%dolar##########/g\\\" '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i \\\"s/@/\\\$/g\\\" '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"source ${BUILD_SOURCE_FILE} && eval \\\"echo '\$(cat ${TMP_DOCKER_FOLDER}/${counter}/'${FILE_NAME}')' \\\"\" >> ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i \\\"s/[\\\$]/@/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i \\\"s/%%%%%%%%%%dolar##########/\\\$/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i 's/%%%%%%%%%%quot##########/\\\"/g' ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"sed -i \\\"s/%%%%%%%%%%apos##########/'/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"source ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc; RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${FILE_NAME}'\033[0m\\\"; exit -1; fi \" && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"cat ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" >> ${IMAGE_SOURCE_FILE} && \\ \n"
        DOCKERFILE_CONTEND+="/bin/bash -c \"echo\" >> ${IMAGE_SOURCE_FILE} && \\ \n"
        DOCKERFILE_CONTEND+="echo \"\033[1;35m> Done!\033[0m\" && \\ \n"
        DOCKERFILE_CONTEND+="echo #DO_NOT_PRINT \n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[ \033[1;35mIMAGE SOURCE ADDED\033[0m      ]  ${file}"

    elif [ "$(echo $(basename ${file}) | grep ${DOKERFILE_APPEND})" != "" ]
    then
        #> Add source to source file
        DOCKERFILE_CONTEND+="# Append build source file '${TMP_DOCKER_FOLDER}/${counter}/${FILE_NAME}'\n"
        DOCKERFILE_CONTEND+=$(cat ${file})
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[ \033[1;36mDOCKERFILE APPEND ADDED\033[0m ]  ${file}"
    fi
done


#> Exit if only display file order
if [ "${ONLY_DISPLAY_FILE_ORDER}" != "" ]
then
    exit 0
fi


#> Set image export
DOCKERFILE_CONTEND+="RUN /bin/bash -c \"cat ${IMAGE_SOURCE_FILE}\" >> /etc/bash.bashrc\n"


#> Clean step
if [ "${KEEP_TMP_FILES}" == "" ]
then
    DOCKERFILE_CONTEND+="RUN rm -rf \"${TMP_DOCKER_FOLDER}\""
fi

#> Put generated code in file
cat $DOCKERFILE_PATH | while read LINE
do
    if [ "${LINE}" = "${GENERATE_CONTENT_LABEL}" ]
    then
        echo -e "${DOCKERFILE_CONTEND}" >> ${CREATED_DOCKER_FILE}
        DOCKERFILE_CONTEND=""
    else
        echo -e "${LINE}" >> ${CREATED_DOCKER_FILE}
    fi
done


#> Execute docker build
log ""
bash -c "docker build -t ${DOCKER_IMAGE_NAME} -f ${CREATED_DOCKER_FILE} ${DOCKER_BUILD_ARGS} ${DOCKER_BUILD_EXTRA_ARGS} . " 2>&1 | grep -v "DO_NOT_PRINT"
if [ ${PIPESTATUS[0]} != 0 ]
then
    echo "Error!"
    exit -1
fi


#> Start debug session
if [ ! "${DEBUG_FOLDER}" = "" ]
then
    (
        log ""
        set -x
        docker run \
                    -it \
                    --rm \
                    --name $(echo ${DOCKER_IMAGE_NAME} | sed -e "s/:.*$//g")_debug \
                    -v ${DEBUG_FOLDER}:${DOCKER_DEBUG_FOLDER} \
                    -w ${DOCKER_WORKSPACE} \
                    ${DOCKER_IMAGE_NAME}
    )
fi


#> Remove temporal files
rm ${CREATED_DOCKER_FILE}