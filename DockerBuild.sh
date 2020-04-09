#!/bin/bash
set -e


#> Log
function log {
    echo -e "$@"
}

#> Variables
TMP_DOCKER_FOLDER="/tmp/docker_build"
SORT_STRING="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
SORT_STRING0="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
SORT_STRING1="dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
SORT_STRING2="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
SORT_STRING3="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
SORT_STRING4="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
SORT_STRING5="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
EXEC_SORT_KEY="Dockerfile."
EXEC="${EXEC_SORT_KEY}sh"
EXEC_DEBUG="${EXEC_SORT_KEY}debug.sh"
PRE_EXPORT="Pre"
POST_EXPORT="Post"
IMGAGE_EXPORT="Img"
PRE_EXPORT_SOURCE="${EXEC_SORT_KEY}${PRE_EXPORT}Export.source"
POST_EXPORT_SOURCE="${EXEC_SORT_KEY}${POST_EXPORT}Export.source"
PRE_IEXPORT_SOURCE="${EXEC_SORT_KEY}${IMGAGE_EXPORT}${PRE_EXPORT}Export.source"
POST_IEXPORT_SOURCE="${EXEC_SORT_KEY}${IMGAGE_EXPORT}${POST_EXPORT}Export.source"
CREATED_DOCKER_FILE=".Dockerfile"
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
            log "It will look for '${EXEC}', '${PRE_EXPORT_SOURCE}'. '${PRE_IEXPORT_SOURCE}' and '${POST_IEXPORT_SOURCE}' files and add them to the docker image build steps sorting them by name and nesting level position."
            log ""
            log ""
            log "File description"
            log "  ${EXEC}: shell script that will be executed in a docker build step. In order to debug it, change the file name to '${EXEC_DEBUG}'."
            log "  ${PRE_EXPORT_SOURCE}: Source file that will be included only in the build process BEFORE execute '${EXEC}' script placed in the same folder."
            log "  ${POST_EXPORT_SOURCE}: Source file that will be included only in the build process AFTER execute '${EXEC}' script placed in the same folder."
            log "  ${PRE_IEXPORT_SOURCE}: Source file that will be included to the docker container execution and build process BEFORE execute '${EXEC}' script placed in the same folder."
            log "  ${POST_IEXPORT_SOURCE}: Source file that will be included to the docker container execution and build process AFTER execute '${EXEC}' script placed in the same folder."
            log ""
            log ""
            log " DockerBuild.sh comand args help"
            log ""
            log "  -D \t Folder where Dockerfile is place. By default is the calling directory."
            log "  -d \t Folder where script will start the search of '${EXEC}', '${PRE_EXPORT_SOURCE}', '${POST_EXPORT_SOURCE}' and '${POST_IEXPORT_SOURCE}' files. This path can't be lower than the Dockerfile folder. By default is the Dockerfile folder."
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
DOCKERFILE_CONTEND+="RUN mkdir -p \"${TMP_DOCKER_FOLDER}/\"\n"
DOCKERFILE_CONTEND+="RUN touch \"${BUILD_SOURCE_FILE}\"\n"
DOCKERFILE_CONTEND+="RUN touch \"${IMAGE_SOURCE_FILE}\"\n"
DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo\" >> /etc/bash.bashrc\n"
DOCKERFILE_CONTEND+="\n"
DOCKERFILE_CONTEND+="\n"


#> Find files and sort them
IFS=";"
FOUND_FILES=$(find ${DOCKERFILE_SCRIPTS_START_SEARCH} -type f -name "${EXEC}" \
                                                          -or -name "${EXEC_DEBUG}" \
                                                          -or -name "${PRE_EXPORT_SOURCE}" \
                                                          -or -name "${POST_EXPORT_SOURCE}" \
                                                          -or -name "${PRE_IEXPORT_SOURCE}" \
                                                          -or -name "${POST_IEXPORT_SOURCE}" \
                                                            | sed "s/${EXEC}$/${SORT_STRING}${SORT_STRING0}/g" \
                                                            | sed "s/${EXEC_DEBUG}$/${SORT_STRING}${SORT_STRING1}/g" \
                                                            | sed "s/${PRE_EXPORT_SOURCE}$/${SORT_STRING}${SORT_STRING2}/g" \
                                                            | sed "s/${PRE_IEXPORT_SOURCE}$/${SORT_STRING}${SORT_STRING3}/g" \
                                                            | sed "s/${POST_EXPORT_SOURCE}$/${SORT_STRING}${SORT_STRING4}/g" \
                                                            | sed "s/${POST_IEXPORT_SOURCE}$/${SORT_STRING}${SORT_STRING5}/g" \
                                                            | sort \
                                                            | sed "s/${SORT_STRING}${SORT_STRING5}/${POST_IEXPORT_SOURCE}/g" \
                                                            | sed "s/${SORT_STRING}${SORT_STRING4}/${POST_EXPORT_SOURCE}/g" \
                                                            | sed "s/${SORT_STRING}${SORT_STRING3}/${PRE_IEXPORT_SOURCE}/g" \
                                                            | sed "s/${SORT_STRING}${SORT_STRING2}/${PRE_EXPORT_SOURCE}/g" \
                                                            | sed "s/${SORT_STRING}${SORT_STRING1}/${EXEC_DEBUG}/g" \
                                                            | sed "s/${SORT_STRING}${SORT_STRING0}/${EXEC}/g" \
                                                            | while read file; do echo -ne "${file};"; done;)


#> Find build scripts
counter=0
for file in ${FOUND_FILES}
do

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
    if [ "$(basename ${file})" = "${EXEC_DEBUG}" ]
    then
        DEBUG_FOLDER=$(realpath $(dirname "$file"))
        DOCKERFILE_CONTEND+="RUN cat ${BUILD_SOURCE_FILE} >> /etc/bash.bashrc\n"
        DOCKERFILE_CONTEND+="ENTRYPOINT cp -r ${DOCKER_DEBUG_FOLDER}/* ${DOCKER_WORKSPACE}/ && ln -sf ${DOCKER_DEBUG_FOLDER}/${EXEC_DEBUG} ${DOCKER_WORKSPACE}/${EXEC_DEBUG} && bash \n"

        log "[DOCKERFILE DEBUG STEP]  ${file}"

        break


    elif [ "$(basename ${file})" = "${EXEC}" ]
    then
        #> Exec install steps
        DOCKERFILE_CONTEND+="# Building '${SOURCE_DIR}/${EXEC}' #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN chmod u+x \"${TMP_DOCKER_FOLDER}/${counter}/${EXEC}\" \n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Building '${SOURCE_DIR}/${EXEC}'...\033[0m\n"
        DOCKERFILE_CONTEND+="RUN cd \"${TMP_DOCKER_FOLDER}/${counter}/\" && /bin/bash -c \"source ${BUILD_SOURCE_FILE} && source ${IMAGE_SOURCE_FILE} && (set -xe; . ./${EXEC}); RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${EXEC}'\033[0m\\\"; exit -1; fi \" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Done!\033[0m\n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[DOCKERFILE STEP ADDED]  ${file}"

    elif [ "$(basename ${file})" = "${PRE_EXPORT_SOURCE}" ]
    then
        #> Add source to source file
        DOCKERFILE_CONTEND+="# Append build source file '${TMP_DOCKER_FOLDER}/${counter}/${PRE_EXPORT_SOURCE}' #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo '# Source from ${SOURCE_DIR}/${PRE_EXPORT_SOURCE}' \" >> ${BUILD_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Adding source '${SOURCE_DIR}/${PRE_EXPORT_SOURCE}'...\033[0m\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"source ${TMP_DOCKER_FOLDER}/${counter}/${PRE_EXPORT_SOURCE}; RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${PRE_EXPORT_SOURCE}'\033[0m\\\"; exit -1; fi \" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"cat ${TMP_DOCKER_FOLDER}/${counter}/${PRE_EXPORT_SOURCE}\" >> ${BUILD_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo \" >> ${BUILD_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Done!\033[0m\n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[BUILD SOURCE ADDED   ]  ${file}"

    elif [ "$(basename ${file})" = "${POST_EXPORT_SOURCE}" ]
    then
        #> Add source to source file
        DOCKERFILE_CONTEND+="# Append build source file '${TMP_DOCKER_FOLDER}/${counter}/${POST_EXPORT_SOURCE}' #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo '# Source from ${SOURCE_DIR}/${POST_EXPORT_SOURCE}' \" >> ${BUILD_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Adding source '${SOURCE_DIR}/${POST_EXPORT_SOURCE}'...\033[0m\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"source ${TMP_DOCKER_FOLDER}/${counter}/${POST_EXPORT_SOURCE}; RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${PRE_EXPORT_SOURCE}'\033[0m\\\"; exit -1; fi \" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"cat ${TMP_DOCKER_FOLDER}/${counter}/${POST_EXPORT_SOURCE}\" >> ${BUILD_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo \" >> ${BUILD_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Done!\033[0m\n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[BUILD SOURCE ADDED   ]  ${file}"


    elif [ "$(basename ${file})" == "${POST_IEXPORT_SOURCE}" ]
    then
        #> Add source to source file and to bash rc file
        DOCKERFILE_CONTEND+="# Append image source file '${TMP_DOCKER_FOLDER}/${counter}/${POST_IEXPORT_SOURCE}'\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo '# Source from ${SOURCE_DIR}/${POST_IEXPORT_SOURCE}' \" >> ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Adding source '${SOURCE_DIR}/${POST_IEXPORT_SOURCE}'...\033[0m\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i 's/\\\"/%%%%%%%%%%quot##########/g' ${TMP_DOCKER_FOLDER}/${counter}/${POST_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/'/%%%%%%%%%%apos##########/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/${POST_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/[\\\$]/%%%%%%%%%%dolar##########/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/${POST_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/@/\\\$/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/${POST_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"source ${BUILD_SOURCE_FILE} && eval \\\"echo '\$(cat ${TMP_DOCKER_FOLDER}/${counter}/${POST_IEXPORT_SOURCE})' \\\"\" >> ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/[\\\$]/@/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/%%%%%%%%%%dolar##########/\\\$/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i 's/%%%%%%%%%%quot##########/\\\"/g' ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/%%%%%%%%%%apos##########/'/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"source ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc; RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${POST_IEXPORT_SOURCE}'\033[0m\\\"; exit -1; fi \" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"cat ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" >> ${IMAGE_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo\" >> ${IMAGE_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Done!\033[0m\n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[IMAGE SOURCE ADDED   ]  ${file}"


    elif [ "$(basename ${file})" == "${PRE_IEXPORT_SOURCE}" ]
    then
        #> Add source to source file and to bash rc file
        DOCKERFILE_CONTEND+="# Append image source file '${TMP_DOCKER_FOLDER}/${counter}/${PRE_IEXPORT_SOURCE}'\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo '# Source from ${SOURCE_DIR}/${PRE_IEXPORT_SOURCE}' \" >> ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Adding source '${SOURCE_DIR}/${PRE_IEXPORT_SOURCE}'...\033[0m\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i 's/\\\"/%%%%%%%%%%quot##########/g' ${TMP_DOCKER_FOLDER}/${counter}/${PRE_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/'/%%%%%%%%%%apos##########/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/${PRE_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/[\\\$]/%%%%%%%%%%dolar##########/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/${PRE_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/@/\\\$/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/${PRE_IEXPORT_SOURCE}\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"source ${BUILD_SOURCE_FILE} && eval \\\"echo '\$(cat ${TMP_DOCKER_FOLDER}/${counter}/${PRE_IEXPORT_SOURCE})' \\\"\" >> ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/[\\\$]/@/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/%%%%%%%%%%dolar##########/\\\$/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i 's/%%%%%%%%%%quot##########/\\\"/g' ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"sed -i \\\"s/%%%%%%%%%%apos##########/'/g\\\" ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"source ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc; RESULT=\\\$?; if [ ! \\\$RESULT = 0 ]; then echo \\\"\033[1;35mError at '${SOURCE_DIR}/${PRE_IEXPORT_SOURCE}'\033[0m\\\"; exit -1; fi \" #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"cat ${TMP_DOCKER_FOLDER}/${counter}/bash.bashrc\" >> ${IMAGE_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN /bin/bash -c \"echo\" >> ${IMAGE_SOURCE_FILE} #DO_NOT_PRINT\n"
        DOCKERFILE_CONTEND+="RUN #\033[1;32m Done!\033[0m\n"
        DOCKERFILE_CONTEND+="\n"
        DOCKERFILE_CONTEND+="\n"

        log "[IMAGE SOURCE ADDED   ]  ${file}"
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


#> root command required
if [ "$EUID" -ne 0 ]
then
    ROOT_COMMAND="sudo"
fi

#> Execute docker build
log ""
bash -c "${ROOT_COMMAND} docker build -t ${DOCKER_IMAGE_NAME} -f ${CREATED_DOCKER_FILE} ${DOCKER_BUILD_ARGS} ${DOCKER_BUILD_EXTRA_ARGS} . " 2>&1 | grep -v "DO_NOT_PRINT"
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