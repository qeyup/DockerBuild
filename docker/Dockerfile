FROM ubuntu:18.04


########################################
# Docker image name
#DB DOCKER_IMAGE_NAME=pypi_upload

# Docker build defined args
#DB DOCKER_BUILD_ARGS=

########################################

#[AUTOGENERATED IMAGE CODE BEGIN]


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Dockerfile content autogenerated by DockerBuild v0.4.0
# https://pypi.org/project/DockerBuild/
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Add required scripts
RUN mkdir -p /tmp/dockerbuild && \
echo "#!/bin/bash" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "set -o pipefail" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "# Get args" >> /tmp/dockerbuild/BuildScript && \
echo "TYPE=\${1}" >> /tmp/dockerbuild/BuildScript && \
echo "EXEC_FILE=\"\${3}\"" >> /tmp/dockerbuild/BuildScript && \
echo "EXEC_PATH=\$(realpath \"\${2}\")" >> /tmp/dockerbuild/BuildScript && \
echo "FILE=\$(realpath \"\${2}/\${3}\")" >> /tmp/dockerbuild/BuildScript && \
echo "MAIN_WORKING_PATH=\"/tmp/dockerbuild/\"" >> /tmp/dockerbuild/BuildScript && \
echo "CURRENT_WORKING_PATH=/tmp/dockerbuild/current_build" >> /tmp/dockerbuild/BuildScript && \
echo "REL_PATH=\$(realpath --relative-to=\${MAIN_WORKING_PATH} \"\${EXEC_PATH}\")" >> /tmp/dockerbuild/BuildScript && \
echo "BUILD_SOURCE_DIR=\"/etc/dockerbuild/bsource.d\"" >> /tmp/dockerbuild/BuildScript && \
echo "IMAGE_SOURCE_DIR=\"/etc/dockerbuild/source.d\"" >> /tmp/dockerbuild/BuildScript && \
echo "ENTRYPOINT_DIR=\"/etc/dockerbuild/entrypoint.d\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "LABEL_COLOR=\" [94m\"" >> /tmp/dockerbuild/BuildScript && \
echo "TRACE_COLOR=\"[0m\"" >> /tmp/dockerbuild/BuildScript && \
echo "ERROR_COLOR=\"[91m\"" >> /tmp/dockerbuild/BuildScript && \
echo "SUCCESS_COLOR=\"[1;32m\"" >> /tmp/dockerbuild/BuildScript && \
echo "REMOVE_FORMAT=\"[0m\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "replaceVariables(){" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    FILE=\"\${1}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Load sources" >> /tmp/dockerbuild/BuildScript && \
echo "    for SOURCE_FILE in \$(cd / && find \$BUILD_SOURCE_DIR -type f 2>/dev/null | sort); do" >> /tmp/dockerbuild/BuildScript && \
echo "        source \"\${SOURCE_FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    done" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Add end line" >> /tmp/dockerbuild/BuildScript && \
echo "    echo \"\" >> \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Replace @ variables" >> /tmp/dockerbuild/BuildScript && \
echo "    cat \"\${FILE}\" | while read LINE" >> /tmp/dockerbuild/BuildScript && \
echo "    do" >> /tmp/dockerbuild/BuildScript && \
echo "        OLD_IFS=\${IFS}" >> /tmp/dockerbuild/BuildScript && \
echo "        IFS=\"@\"" >> /tmp/dockerbuild/BuildScript && \
echo "        for WORD in \${LINE}; do" >> /tmp/dockerbuild/BuildScript && \
echo "            IFS=\${OLD_IFS}" >> /tmp/dockerbuild/BuildScript && \
echo "            WORD=\"@\${WORD}\"" >> /tmp/dockerbuild/BuildScript && \
echo "            WORD=\$(echo \"\${WORD}\" | grep -o \"@{.*}\")" >> /tmp/dockerbuild/BuildScript && \
echo "            RLINE=\$(echo \"\${WORD}\" | sed \"s/@/\\$/g\")" >> /tmp/dockerbuild/BuildScript && \
echo "            VALUE=\$(eval \"echo \"\${RLINE}\"\")" >> /tmp/dockerbuild/BuildScript && \
echo "            if [ ! \"\${VALUE}\" == \"\" ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "                replaceVariable()(" >> /tmp/dockerbuild/BuildScript && \
echo "                    if [ \"\$(echo \"\${VALUE}\" | grep \"\${1}\")\" == \"\" ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "                        sed -i \"s\${1}\${WORD}\${1}\${VALUE}\${1}g\" \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "                        exit 0" >> /tmp/dockerbuild/BuildScript && \
echo "                    else" >> /tmp/dockerbuild/BuildScript && \
echo "                        exit -1" >> /tmp/dockerbuild/BuildScript && \
echo "                    fi" >> /tmp/dockerbuild/BuildScript && \
echo "                )" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "                # Replace using non-used delimiter" >> /tmp/dockerbuild/BuildScript && \
echo "                #for DEL in \$(printf \"\$(printf '\x % x ' {32..126})\")" >> /tmp/dockerbuild/BuildScript && \
echo "                for DEL in \"#\" \"|\" \"/\" \"*\" \"_\" \"+\" \"?\" \"-\" \"<\" \">\" \":\" \".\" \";\" \"^\"" >> /tmp/dockerbuild/BuildScript && \
echo "                do" >> /tmp/dockerbuild/BuildScript && \
echo "                    if replaceVariable \"\${DEL}\"; then" >> /tmp/dockerbuild/BuildScript && \
echo "                        REPLACED=\"True\"" >> /tmp/dockerbuild/BuildScript && \
echo "                        break" >> /tmp/dockerbuild/BuildScript && \
echo "                    fi" >> /tmp/dockerbuild/BuildScript && \
echo "                done" >> /tmp/dockerbuild/BuildScript && \
echo "                if [ \"\$REPLACED\" == \"\" ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "                    echo \"\${ERROR_COLOR} Can't replace \${WORD} with \${VALUE} \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "                    exit -1" >> /tmp/dockerbuild/BuildScript && \
echo "                fi" >> /tmp/dockerbuild/BuildScript && \
echo "            fi" >> /tmp/dockerbuild/BuildScript && \
echo "            IFS=\"@\"" >> /tmp/dockerbuild/BuildScript && \
echo "        done" >> /tmp/dockerbuild/BuildScript && \
echo "        IFS=\${OLD_IFS}" >> /tmp/dockerbuild/BuildScript && \
echo "    done" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \$? -ne 0 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        exit -1" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "CRLF_2_LF(){" >> /tmp/dockerbuild/BuildScript && \
echo "    FILE=\"\${1}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    sed -i 's/\r\$//' \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "buildStep(){" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    mv \"\${EXEC_PATH}\" \"\${CURRENT_WORKING_PATH}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    cd \"\${CURRENT_WORKING_PATH}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${EXEC_FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    chmod u+x \"\${EXEC_FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # exec" >> /tmp/dockerbuild/BuildScript && \
echo "    (" >> /tmp/dockerbuild/BuildScript && \
echo "        for SOURCE_FILE in \$(cd / && find \$BUILD_SOURCE_DIR -type f 2>/dev/null | sort); do" >> /tmp/dockerbuild/BuildScript && \
echo "            source \"\${SOURCE_FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        done" >> /tmp/dockerbuild/BuildScript && \
echo "        set -x" >> /tmp/dockerbuild/BuildScript && \
echo "        . \"\${EXEC_FILE}\" 2>&1" >> /tmp/dockerbuild/BuildScript && \
echo "    ) 2>/dev/null | while read line; do echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${TRACE_COLOR} \${line} \${REMOVE_FORMAT}\"; done;" >> /tmp/dockerbuild/BuildScript && \
echo "    RESULT=\"\$?\"" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \${RESULT} -ne 0 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${ERROR_COLOR} Error(\${RESULT})! \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        exit -1" >> /tmp/dockerbuild/BuildScript && \
echo "    else" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        mv \"\${CURRENT_WORKING_PATH}\" \"\${EXEC_PATH}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        exit 0" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "buildSource(){" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${BUILD_SOURCE_DIR}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    BUILD_SOURCE_NAME=\$((\$(ls -1 \${BUILD_SOURCE_DIR} | wc -l) + 1))" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \${BUILD_SOURCE_NAME} -lt 10 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"000\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 100 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"00\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 1000 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"0\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Repace variables" >> /tmp/dockerbuild/BuildScript && \
echo "    replaceVariables \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Copiar" >> /tmp/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Probar" >> /tmp/dockerbuild/BuildScript && \
echo "    (" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"Testing \${FILE} -> \${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        source \"\${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    ) 2>/dev/null | while read line; do echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${TRACE_COLOR} \${line} \${REMOVE_FORMAT}\"; done;" >> /tmp/dockerbuild/BuildScript && \
echo "    RESULT=\"\$?\"" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \${RESULT} -ne 0 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${ERROR_COLOR} Error(\${RESULT})! \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        exit -1" >> /tmp/dockerbuild/BuildScript && \
echo "    else" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        exit 0" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "imageSource(){" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${IMAGE_SOURCE_DIR}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${BUILD_SOURCE_DIR}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    IMAGE_SOURCE_NAME=\$((\$(ls -1 \${IMAGE_SOURCE_DIR} | wc -l) + 1))" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \${IMAGE_SOURCE_NAME} -lt 10 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        IMAGE_SOURCE_NAME=\"000\${IMAGE_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${IMAGE_SOURCE_NAME} -lt 100 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        IMAGE_SOURCE_NAME=\"00\${IMAGE_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${IMAGE_SOURCE_NAME} -lt 1000 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        IMAGE_SOURCE_NAME=\"0\${IMAGE_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "    BUILD_SOURCE_NAME=\$((\$(ls -1 \${BUILD_SOURCE_DIR} | wc -l) + 1))" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \${BUILD_SOURCE_NAME} -lt 10 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"000\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 100 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"00\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 1000 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"0\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Repace variables" >> /tmp/dockerbuild/BuildScript && \
echo "    replaceVariables \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Copiar" >> /tmp/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${IMAGE_SOURCE_DIR}/\${IMAGE_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Probar" >> /tmp/dockerbuild/BuildScript && \
echo "    (" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"Testing \${FILE} -> \${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"Testing \${FILE} -> \${IMAGE_SOURCE_DIR}/\${IMAGE_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        source \"\${IMAGE_SOURCE_DIR}/\${IMAGE_SOURCE_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    ) 2>/dev/null | while read line; do echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${TRACE_COLOR} \${line} \${REMOVE_FORMAT}\"; done;" >> /tmp/dockerbuild/BuildScript && \
echo "    RESULT=\"\$?\"" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \${RESULT} -ne 0 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${ERROR_COLOR} Error(\${RESULT})! \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        exit -1" >> /tmp/dockerbuild/BuildScript && \
echo "    else" >> /tmp/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "        exit 0" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "entryPoint(){" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${ENTRYPOINT_DIR}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    ENTRYPOINT_NAME=\$((\$(ls -1 \${ENTRYPOINT_DIR} | wc -l) + 1))" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ \${ENTRYPOINT_NAME} -lt 10 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        ENTRYPOINT_NAME=\"000\${ENTRYPOINT_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${ENTRYPOINT_NAME} -lt 100 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        ENTRYPOINT_NAME=\"00\${ENTRYPOINT_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    elif [ \${ENTRYPOINT_NAME} -lt 1000 ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        ENTRYPOINT_NAME=\"0\${ENTRYPOINT_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Repace variables" >> /tmp/dockerbuild/BuildScript && \
echo "    replaceVariables \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # Copiar" >> /tmp/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${ENTRYPOINT_DIR}/\${ENTRYPOINT_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    chmod u+x \"\${ENTRYPOINT_DIR}/\${ENTRYPOINT_NAME}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    # No test" >> /tmp/dockerbuild/BuildScript && \
echo "    echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    exit 0" >> /tmp/dockerbuild/BuildScript && \
echo "}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "debugFile(){" >> /tmp/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${EXEC_PATH}\"" >> /tmp/dockerbuild/BuildScript && \
echo "    mv \"\${EXEC_PATH}\" \"\${CURRENT_WORKING_PATH}\"" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    rm -rf \${IMAGE_SOURCE_DIR}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "    if [ -d \${BUILD_SOURCE_DIR} ]; then" >> /tmp/dockerbuild/BuildScript && \
echo "        ln -s \${BUILD_SOURCE_DIR} \${IMAGE_SOURCE_DIR}" >> /tmp/dockerbuild/BuildScript && \
echo "    fi" >> /tmp/dockerbuild/BuildScript && \
echo "    ln -s \"/tmp/dockerbuild/debug_folder/\${EXEC_FILE}\" \"\${CURRENT_WORKING_PATH}/\${EXEC_FILE}\"" >> /tmp/dockerbuild/BuildScript && \
echo "}" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "case \"\$TYPE\" in" >> /tmp/dockerbuild/BuildScript && \
echo "    Dockerfile.sh) buildStep ;;" >> /tmp/dockerbuild/BuildScript && \
echo "    BuildExport) buildSource ;;" >> /tmp/dockerbuild/BuildScript && \
echo "    ImageExport) imageSource ;;" >> /tmp/dockerbuild/BuildScript && \
echo "    Entrypoint.sh) entryPoint ;;" >> /tmp/dockerbuild/BuildScript && \
echo "    Debug) debugFile ;;" >> /tmp/dockerbuild/BuildScript && \
echo "    *) exit -1 ;;" >> /tmp/dockerbuild/BuildScript && \
echo "esac" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript && \
echo "" >> /tmp/dockerbuild/BuildScript
RUN chmod u+x /tmp/dockerbuild/BuildScript


#--------------------------------------------------------------------------------------------------------------------------------
# Image: pypi_upload (/home/moe/Projects/DockerBuild/docker/Dockerfile)

# Build step 'Dockerfile.sh'
COPY ["Dockerfile.sh", "/tmp/dockerbuild/pypi_upload/Dockerfile.sh"]
RUN /tmp/dockerbuild/BuildScript Dockerfile.sh "/tmp/dockerbuild/pypi_upload" "Dockerfile.sh"


# Raw append 'DockerfileAppend'
WORKDIR /root/workspace





# Add clean workspace
RUN rm -rf /tmp/dockerbuild/






#[AUTOGENERATED IMAGE CODE END]



