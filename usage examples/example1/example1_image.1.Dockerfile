FROM ubuntu:18.04

########################################
#DB INCLUDE example1_nested1
#DB INCLUDE example1_nested2

# Docker image name
#DB DOCKER_IMAGE_NAME example1_image:1

# Docker build defined args
#DB DOCKER_BUILD_ARGS

#[AUTOGENERATED IMAGE CODE BEGIN]


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Dockerfile content autogenerated by DockerBuild v0.6.1
# https://pypi.org/project/DockerBuild/
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Add required scripts
RUN mkdir -p /etc/dockerbuild && \
echo "#!/bin/bash" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "set -o pipefail" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "# Get args" >> /etc/dockerbuild/BuildScript && \
echo "TYPE=\${1}" >> /etc/dockerbuild/BuildScript && \
echo "EXEC_FILE=\"\${3}\"" >> /etc/dockerbuild/BuildScript && \
echo "EXEC_PATH=\$(realpath \"\${2}\")" >> /etc/dockerbuild/BuildScript && \
echo "FILE=\$(realpath \"\${2}/\${3}\")" >> /etc/dockerbuild/BuildScript && \
echo "KEEP_FILES=\${4}" >> /etc/dockerbuild/BuildScript && \
echo "MAIN_WORKING_PATH=\"/tmp/dockerbuild/\"" >> /etc/dockerbuild/BuildScript && \
echo "CURRENT_WORKING_PATH=/tmp/dockerbuild/current_build" >> /etc/dockerbuild/BuildScript && \
echo "REL_PATH=\$(realpath --relative-to=\${MAIN_WORKING_PATH} \"\${EXEC_PATH}\")" >> /etc/dockerbuild/BuildScript && \
echo "BUILD_SOURCE_DIR=\"/etc/dockerbuild/bsource.d\"" >> /etc/dockerbuild/BuildScript && \
echo "IMAGE_SOURCE_DIR=\"/etc/dockerbuild/source.d\"" >> /etc/dockerbuild/BuildScript && \
echo "ENTRYPOINT_DIR=\"/etc/dockerbuild/entrypoint.d\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "LABEL_COLOR=\" [94m\"" >> /etc/dockerbuild/BuildScript && \
echo "TRACE_COLOR=\"[0m\"" >> /etc/dockerbuild/BuildScript && \
echo "ERROR_COLOR=\"[91m\"" >> /etc/dockerbuild/BuildScript && \
echo "SUCCESS_COLOR=\"[1;32m\"" >> /etc/dockerbuild/BuildScript && \
echo "REMOVE_FORMAT=\"[0m\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "replaceVariables(){" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    FILE=\"\${1}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Load sources" >> /etc/dockerbuild/BuildScript && \
echo "    for SOURCE_FILE in \$(cd / && find \$BUILD_SOURCE_DIR -type f 2>/dev/null | sort); do" >> /etc/dockerbuild/BuildScript && \
echo "        source \"\${SOURCE_FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "    done" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Add end line" >> /etc/dockerbuild/BuildScript && \
echo "    echo \"\" >> \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Replace @ variables" >> /etc/dockerbuild/BuildScript && \
echo "    cat \"\${FILE}\" | while read LINE" >> /etc/dockerbuild/BuildScript && \
echo "    do" >> /etc/dockerbuild/BuildScript && \
echo "        OLD_IFS=\${IFS}" >> /etc/dockerbuild/BuildScript && \
echo "        IFS=\"@\"" >> /etc/dockerbuild/BuildScript && \
echo "        for WORD in \${LINE}; do" >> /etc/dockerbuild/BuildScript && \
echo "            IFS=\${OLD_IFS}" >> /etc/dockerbuild/BuildScript && \
echo "            WORD=\"@\${WORD}\"" >> /etc/dockerbuild/BuildScript && \
echo "            WORD=\$(echo \"\${WORD}\" | grep -o \"@{.*}\")" >> /etc/dockerbuild/BuildScript && \
echo "            RLINE=\$(echo \"\${WORD}\" | sed \"s/@/\\$/g\")" >> /etc/dockerbuild/BuildScript && \
echo "            VALUE=\$(eval \"echo \"\${RLINE}\"\")" >> /etc/dockerbuild/BuildScript && \
echo "            if [ ! \"\${VALUE}\" == \"\" ]; then" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "                replaceVariable()(" >> /etc/dockerbuild/BuildScript && \
echo "                    if [ \"\$(echo \"\${VALUE}\" | grep \"\${1}\")\" == \"\" ]; then" >> /etc/dockerbuild/BuildScript && \
echo "                        sed -i \"s\${1}\${WORD}\${1}\${VALUE}\${1}g\" \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "                        exit 0" >> /etc/dockerbuild/BuildScript && \
echo "                    else" >> /etc/dockerbuild/BuildScript && \
echo "                        exit -1" >> /etc/dockerbuild/BuildScript && \
echo "                    fi" >> /etc/dockerbuild/BuildScript && \
echo "                )" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "                # Replace using non-used delimiter" >> /etc/dockerbuild/BuildScript && \
echo "                #for DEL in \$(printf \"\$(printf '\x % x ' {32..126})\")" >> /etc/dockerbuild/BuildScript && \
echo "                for DEL in \"#\" \"|\" \"/\" \"*\" \"_\" \"+\" \"?\" \"-\" \"<\" \">\" \":\" \".\" \";\" \"^\"" >> /etc/dockerbuild/BuildScript && \
echo "                do" >> /etc/dockerbuild/BuildScript && \
echo "                    if replaceVariable \"\${DEL}\"; then" >> /etc/dockerbuild/BuildScript && \
echo "                        REPLACED=\"True\"" >> /etc/dockerbuild/BuildScript && \
echo "                        break" >> /etc/dockerbuild/BuildScript && \
echo "                    fi" >> /etc/dockerbuild/BuildScript && \
echo "                done" >> /etc/dockerbuild/BuildScript && \
echo "                if [ \"\$REPLACED\" == \"\" ]; then" >> /etc/dockerbuild/BuildScript && \
echo "                    echo \"\${ERROR_COLOR} Can't replace \${WORD} with \${VALUE} \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "                    exit -1" >> /etc/dockerbuild/BuildScript && \
echo "                fi" >> /etc/dockerbuild/BuildScript && \
echo "            fi" >> /etc/dockerbuild/BuildScript && \
echo "            IFS=\"@\"" >> /etc/dockerbuild/BuildScript && \
echo "        done" >> /etc/dockerbuild/BuildScript && \
echo "        IFS=\${OLD_IFS}" >> /etc/dockerbuild/BuildScript && \
echo "    done" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \$? -ne 0 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        exit -1" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "CRLF_2_LF(){" >> /etc/dockerbuild/BuildScript && \
echo "    FILE=\"\${1}\"" >> /etc/dockerbuild/BuildScript && \
echo "    sed -i 's/\r\$//' \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "buildStep(){" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    mv \"\${EXEC_PATH}\" \"\${CURRENT_WORKING_PATH}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    cd \"\${CURRENT_WORKING_PATH}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${EXEC_FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "    chmod u+x \"\${EXEC_FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # exec" >> /etc/dockerbuild/BuildScript && \
echo "    (" >> /etc/dockerbuild/BuildScript && \
echo "        for SOURCE_FILE in \$(cd / && find \$BUILD_SOURCE_DIR -type f 2>/dev/null | sort); do" >> /etc/dockerbuild/BuildScript && \
echo "            source \"\${SOURCE_FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "        done" >> /etc/dockerbuild/BuildScript && \
echo "        set -x" >> /etc/dockerbuild/BuildScript && \
echo "        . \"\${EXEC_FILE}\" 2>&1" >> /etc/dockerbuild/BuildScript && \
echo "    ) 2>/dev/null | while read line; do echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${TRACE_COLOR} \${line} \${REMOVE_FORMAT}\"; done;" >> /etc/dockerbuild/BuildScript && \
echo "    RESULT=\"\$?\"" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \${RESULT} -ne 0 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${ERROR_COLOR} Error(\${RESULT})! \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "        exit -1" >> /etc/dockerbuild/BuildScript && \
echo "    else" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "        mv \"\${CURRENT_WORKING_PATH}\" \"\${EXEC_PATH}\"" >> /etc/dockerbuild/BuildScript && \
echo "        exit 0" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "buildSource(){" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${BUILD_SOURCE_DIR}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    BUILD_SOURCE_NAME=\$((\$(ls -1 \${BUILD_SOURCE_DIR} | wc -l) + 1))" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \${BUILD_SOURCE_NAME} -lt 10 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"000\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 100 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"00\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 1000 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"0\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Repace variables" >> /etc/dockerbuild/BuildScript && \
echo "    replaceVariables \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Copiar" >> /etc/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Probar" >> /etc/dockerbuild/BuildScript && \
echo "    (" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"Testing \${FILE} -> \${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "        source \"\${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    ) 2>/dev/null | while read line; do echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${TRACE_COLOR} \${line} \${REMOVE_FORMAT}\"; done;" >> /etc/dockerbuild/BuildScript && \
echo "    RESULT=\"\$?\"" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \${RESULT} -ne 0 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${ERROR_COLOR} Error(\${RESULT})! \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "        exit -1" >> /etc/dockerbuild/BuildScript && \
echo "    else" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "        exit 0" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "imageSource(){" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${IMAGE_SOURCE_DIR}\"" >> /etc/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${BUILD_SOURCE_DIR}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    IMAGE_SOURCE_NAME=\$((\$(ls -1 \${IMAGE_SOURCE_DIR} | wc -l) + 1))" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \${IMAGE_SOURCE_NAME} -lt 10 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        IMAGE_SOURCE_NAME=\"000\${IMAGE_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${IMAGE_SOURCE_NAME} -lt 100 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        IMAGE_SOURCE_NAME=\"00\${IMAGE_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${IMAGE_SOURCE_NAME} -lt 1000 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        IMAGE_SOURCE_NAME=\"0\${IMAGE_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "    BUILD_SOURCE_NAME=\$((\$(ls -1 \${BUILD_SOURCE_DIR} | wc -l) + 1))" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \${BUILD_SOURCE_NAME} -lt 10 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"000\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 100 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"00\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${BUILD_SOURCE_NAME} -lt 1000 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        BUILD_SOURCE_NAME=\"0\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Repace variables" >> /etc/dockerbuild/BuildScript && \
echo "    replaceVariables \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Copiar" >> /etc/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${IMAGE_SOURCE_DIR}/\${IMAGE_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Probar" >> /etc/dockerbuild/BuildScript && \
echo "    (" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"Testing \${FILE} -> \${BUILD_SOURCE_DIR}/\${BUILD_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"Testing \${FILE} -> \${IMAGE_SOURCE_DIR}/\${IMAGE_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "        source \"\${IMAGE_SOURCE_DIR}/\${IMAGE_SOURCE_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    ) 2>/dev/null | while read line; do echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${TRACE_COLOR} \${line} \${REMOVE_FORMAT}\"; done;" >> /etc/dockerbuild/BuildScript && \
echo "    RESULT=\"\$?\"" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \${RESULT} -ne 0 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${ERROR_COLOR} Error(\${RESULT})! \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "        exit -1" >> /etc/dockerbuild/BuildScript && \
echo "    else" >> /etc/dockerbuild/BuildScript && \
echo "        echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "        exit 0" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "entryPoint(){" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${ENTRYPOINT_DIR}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    ENTRYPOINT_NAME=\$((\$(ls -1 \${ENTRYPOINT_DIR} | wc -l) + 1))" >> /etc/dockerbuild/BuildScript && \
echo "    if [ \${ENTRYPOINT_NAME} -lt 10 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        ENTRYPOINT_NAME=\"000\${ENTRYPOINT_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${ENTRYPOINT_NAME} -lt 100 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        ENTRYPOINT_NAME=\"00\${ENTRYPOINT_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    elif [ \${ENTRYPOINT_NAME} -lt 1000 ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        ENTRYPOINT_NAME=\"0\${ENTRYPOINT_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Repace variables" >> /etc/dockerbuild/BuildScript && \
echo "    replaceVariables \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "    CRLF_2_LF \"\${FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # Copiar" >> /etc/dockerbuild/BuildScript && \
echo "    cp \"\${FILE}\" \"\${ENTRYPOINT_DIR}/\${ENTRYPOINT_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "    chmod u+x \"\${ENTRYPOINT_DIR}/\${ENTRYPOINT_NAME}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    # No test" >> /etc/dockerbuild/BuildScript && \
echo "    echo \"\${LABEL_COLOR}[\${REL_PATH}/\${EXEC_FILE}]\${SUCCESS_COLOR} Done! \${REMOVE_FORMAT}\"" >> /etc/dockerbuild/BuildScript && \
echo "    exit 0" >> /etc/dockerbuild/BuildScript && \
echo "}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "debugFile(){" >> /etc/dockerbuild/BuildScript && \
echo "    mkdir -p \"\${EXEC_PATH}\"" >> /etc/dockerbuild/BuildScript && \
echo "    mv \"\${EXEC_PATH}\" \"\${CURRENT_WORKING_PATH}\"" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    rm -rf \${IMAGE_SOURCE_DIR}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "    if [ -d \${BUILD_SOURCE_DIR} ]; then" >> /etc/dockerbuild/BuildScript && \
echo "        ln -s \${BUILD_SOURCE_DIR} \${IMAGE_SOURCE_DIR}" >> /etc/dockerbuild/BuildScript && \
echo "    fi" >> /etc/dockerbuild/BuildScript && \
echo "    ln -s \"/tmp/dockerbuild/debug_folder/\${EXEC_FILE}\" \"\${CURRENT_WORKING_PATH}/\${EXEC_FILE}\"" >> /etc/dockerbuild/BuildScript && \
echo "}" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "(" >> /etc/dockerbuild/BuildScript && \
echo "    case \"\$TYPE\" in" >> /etc/dockerbuild/BuildScript && \
echo "        Dockerfile.sh) buildStep ;;" >> /etc/dockerbuild/BuildScript && \
echo "        BuildExport) buildSource ;;" >> /etc/dockerbuild/BuildScript && \
echo "        ImageExport) imageSource ;;" >> /etc/dockerbuild/BuildScript && \
echo "        Entrypoint.sh) entryPoint ;;" >> /etc/dockerbuild/BuildScript && \
echo "        Debug) debugFile ;;" >> /etc/dockerbuild/BuildScript && \
echo "        *) exit -1 ;;" >> /etc/dockerbuild/BuildScript && \
echo "    esac" >> /etc/dockerbuild/BuildScript && \
echo ")" >> /etc/dockerbuild/BuildScript && \
echo "RV=\$?" >> /etc/dockerbuild/BuildScript && \
echo "if [ \"\${KEEP_FILES}\" != \"True\" ]" >> /etc/dockerbuild/BuildScript && \
echo "then" >> /etc/dockerbuild/BuildScript && \
echo "    rm -rf /tmp/dockerbuild/" >> /etc/dockerbuild/BuildScript && \
echo "fi" >> /etc/dockerbuild/BuildScript && \
echo "exit \$RV" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript && \
echo "" >> /etc/dockerbuild/BuildScript
RUN chmod u+x /etc/dockerbuild/BuildScript


#--------------------------------------------------------------------------------------------------------------------------------
# Image: example1_nested1 (./image 1/Dockerfile)

# Build step 'image 1/Dockerfile.sh'
COPY ["image 1/Dockerfile.sh", "/tmp/dockerbuild/example1_nested1/image 1/Dockerfile.sh"]
RUN /etc/dockerbuild/BuildScript Dockerfile.sh "/tmp/dockerbuild/example1_nested1/image 1" "Dockerfile.sh" False


# Add Load image source
RUN echo "for source_file in \$(find -L /etc/dockerbuild/source.d -type f 2> /dev/null | sort); do source \$source_file; done" >> /etc/bash.bashrc


# Build source 'image 1/ImageExport'
COPY ["image 1/ImageExport", "/tmp/dockerbuild/example1_nested1/image 1/ImageExport"]
RUN /etc/dockerbuild/BuildScript ImageExport "/tmp/dockerbuild/example1_nested1/image 1" "ImageExport"




#--------------------------------------------------------------------------------------------------------------------------------
# Image: example1_nested3 (./image 2/image 3/Dockerfile)

# Build source 'image 2/image 3/ImageExport'
COPY ["image 2/image 3/ImageExport", "/tmp/dockerbuild/example1_nested3/image 2/image 3/ImageExport"]
RUN /etc/dockerbuild/BuildScript ImageExport "/tmp/dockerbuild/example1_nested3/image 2/image 3" "ImageExport"




#--------------------------------------------------------------------------------------------------------------------------------
# Image: example1_nested2 (./image 2/Dockerfile)

# Required sources 'image 2/Sources'
ADD ["https://ftp.gnu.org/gnu/glibc/glibc-2.30.tar.xz", "/tmp/dockerbuild/example1_nested2/image 2/glibc.tar.xz"]


# Build source 'image 2/ImageExport'
COPY ["image 2/ImageExport", "/tmp/dockerbuild/example1_nested2/image 2/ImageExport"]
RUN /etc/dockerbuild/BuildScript ImageExport "/tmp/dockerbuild/example1_nested2/image 2" "ImageExport"




#--------------------------------------------------------------------------------------------------------------------------------
# Image: example1_image:1 (./example1_image.1.Dockerfile)

# Required sources 'layer 1/Sources'
ADD ["https://ftp.gnu.org/gnu/glibc/glibc-2.30.tar.xz", "/tmp/dockerbuild/example1_image:1/layer 1/glibc.tar.xz"]


# Build step 'layer 1/1.- Dockerfile.sh'
COPY ["layer 1/1.- Dockerfile.sh", "/tmp/dockerbuild/example1_image:1/layer 1/1.- Dockerfile.sh"]
RUN /etc/dockerbuild/BuildScript Dockerfile.sh "/tmp/dockerbuild/example1_image:1/layer 1" "1.- Dockerfile.sh" True


# Build step 'layer 1/2.- Dockerfile.sh'
COPY ["layer 1/2.- Dockerfile.sh", "/tmp/dockerbuild/example1_image:1/layer 1/2.- Dockerfile.sh"]
RUN /etc/dockerbuild/BuildScript Dockerfile.sh "/tmp/dockerbuild/example1_image:1/layer 1" "2.- Dockerfile.sh" True


# Build source 'layer 1/BuildExport'
COPY ["layer 1/BuildExport", "/tmp/dockerbuild/example1_image:1/layer 1/BuildExport"]
RUN /etc/dockerbuild/BuildScript BuildExport "/tmp/dockerbuild/example1_image:1/layer 1" "BuildExport"


# Build step 'layer 1/Dockerfile.sh'
COPY ["layer 1/Dockerfile.sh", "/tmp/dockerbuild/example1_image:1/layer 1/Dockerfile.sh"]
RUN /etc/dockerbuild/BuildScript Dockerfile.sh "/tmp/dockerbuild/example1_image:1/layer 1" "Dockerfile.sh" False


# Raw append 'layer 2/1. DockerfileAppend'
WORKDIR /root/


# Build source 'layer 2/2. ImageExport'
COPY ["layer 2/2. ImageExport", "/tmp/dockerbuild/example1_image:1/layer 2/2. ImageExport"]
RUN /etc/dockerbuild/BuildScript ImageExport "/tmp/dockerbuild/example1_image:1/layer 2" "2. ImageExport"


# Add Load all entrypoints script
RUN rm -f /etc/dockerbuild/entrypoint.sh && echo "#!/bin/bash" >> /etc/dockerbuild/entrypoint.sh && echo "" >> /etc/dockerbuild/entrypoint.sh && echo "# Load sources" >> /etc/dockerbuild/entrypoint.sh && echo "for SOURCE_FILE in \$(cd / && find /etc/dockerbuild/source.d -type f 2>/dev/null | sort); do" >> /etc/dockerbuild/entrypoint.sh && echo "    source "\${SOURCE_FILE}"" >> /etc/dockerbuild/entrypoint.sh && echo "done" >> /etc/dockerbuild/entrypoint.sh && echo "" >> /etc/dockerbuild/entrypoint.sh && echo "# Load all entrypoints" >> /etc/dockerbuild/entrypoint.sh && echo "for entrypoint_file in \$(cd / && find /etc/dockerbuild/entrypoint.d -type f 2>/dev/null | sort); do" >> /etc/dockerbuild/entrypoint.sh && echo "    \$entrypoint_file &" >> /etc/dockerbuild/entrypoint.sh && echo "done" >> /etc/dockerbuild/entrypoint.sh && echo "" >> /etc/dockerbuild/entrypoint.sh && echo "bash" >> /etc/dockerbuild/entrypoint.sh && echo "" >> /etc/dockerbuild/entrypoint.sh && chmod u+x /etc/dockerbuild/entrypoint.sh


# Entrypoint 'layer 2/3. Entrypoint.sh'
COPY ["layer 2/3. Entrypoint.sh", "/tmp/dockerbuild/example1_image:1/layer 2/3. Entrypoint.sh"]
RUN /etc/dockerbuild/BuildScript Entrypoint.sh "/tmp/dockerbuild/example1_image:1/layer 2" "3. Entrypoint.sh"


# Add Load all entrypoints
ENTRYPOINT ["/etc/dockerbuild/entrypoint.sh"]






#[AUTOGENERATED IMAGE CODE END]


#### test1

#### test2
