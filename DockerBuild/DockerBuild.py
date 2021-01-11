#!/usr/bin/python3

# TODO Mecanismo para guardar logs


# Required modules
import argparse
import os
import sys
import re
import shutil
import glob
import requests
import subprocess
import copy
from hashlib import blake2b
from enum import Enum
from pathlib import Path

import pdb # pdb.set_trace()


# Set version
version="0.2.0"


# Platform
is_windows = hasattr(sys, 'getwindowsversion')


# Global vars
image_from_tag="FROM "
image_name_tag="#DB DOCKER_IMAGE_NAME="
image_build_args_tag="#DB DOCKER_BUILD_ARGS="
image_generate_code_tag="# [DO NOT REMOVE THIS LINE. THIS LINE WILL BE REMPLACED WITH GENERATED CODE]"
image_entrypoint_folder="/etc/dockerbuild/entrypoint.d"
image_entrypoint_file="/etc/dockerbuild/entrypoint.sh"
image_source_folder="/etc/dockerbuild/source.d"
image_bsource_folder="/etc/dockerbuild/bsource.d"
image_working_dir="/tmp/dockerbuild/"
image_current_working_dir="%scurrent_build" % (image_working_dir)
image_debug_folder="%sdebug_folder" % (image_working_dir)
image_build_script="%sBuildScript" % (image_working_dir)

debug_tag="Debug"

created_docker_file=".BuildFile"
created_docker_script=".BuildScript"

docker_file_name="DockerBuild"
docker_file_name_list=[docker_file_name, "Dockerfile"]

source_file_extension="Sources"
source_file_extension_list=[source_file_extension, "RequiredSources"]
exec_extension="Dockerfile.sh"
exec_extension_list=[exec_extension]
entrypoint_extension="Entrypoint.sh"
entrypoint_extension_list=[entrypoint_extension]
dokerfile_append_extension="DockerfileAppend"
dokerfile_append_extension_list=[dokerfile_append_extension]
build_export_source_extension="BuildExport"
build_export_source_extension_list=[build_export_source_extension, "BuildExport.source"]
image_export_source_extension="ImageExport"
image_export_source_extension_list=[image_export_source_extension, "ImageExport.source"]

sort_string="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
sort_string2="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"

files_extensions = []
files_extensions += source_file_extension_list
files_extensions += exec_extension_list
files_extensions += entrypoint_extension_list
files_extensions += dokerfile_append_extension_list
files_extensions += build_export_source_extension_list
files_extensions += image_export_source_extension_list

source_part_extensions = [
    "part"
]

# Description help
short_description="DockerBuild is a 'dockerfile' file generation tools. It converts a file hierarchy tree into a dockerfile."
gen_description = '''

Version: %s

%s

Files types:

    - %s: Source files to be downlaoded.
    - (*)%s: shell script that will be executed in a docker build step.
    - (*)%s: Source file that will be included only in the build process.
    - (*)%s: Source file that will be included to the docker container execution and build process. All @{*} variables will be replaced with the variable value.
    - (*)%s: Entrypoint shell script.
    - (*)%s: Append dockerfile raw layers.


''' % (version, short_description, source_file_extension, exec_extension, image_export_source_extension, build_export_source_extension, entrypoint_extension, dokerfile_append_extension)

# Dockerfile template
docker_file_template = '''
FROM ubuntu:18.04


########################################
# Docker image name
%simage_name

# Docker build defined args
%s

########################################

%s


''' % (image_name_tag, image_build_args_tag, image_generate_code_tag)


# Build layer script
layer_build_script = '''

set -o pipefail

# Get args
TYPE=${1}
EXEC_FILE="${3}"
EXEC_PATH=$(realpath "${2}")
FILE=$(realpath "${2}/${3}")
MAIN_WORKING_PATH="%s"
CURRENT_WORKING_PATH=%s
REL_PATH=$(realpath --relative-to=${MAIN_WORKING_PATH} "${EXEC_PATH}")
BUILD_SOURCE_DIR="%s"
IMAGE_SOURCE_DIR="%s"
ENTRYPOINT_DIR="%s"

LABEL_COLOR=" \033[94m"
TRACE_COLOR="\033[90m"
ERROR_COLOR="\033[91m"
SUCCESS_COLOR="\033[1;32m"
REMOVE_FORMAT="\033[0m"


replaceVariables(){

    FILE="${1}"

    # Load sources
    for SOURCE_FILE in $(cd / && find $BUILD_SOURCE_DIR -type f 2>/dev/null | sort); do
        source "${SOURCE_FILE}"
    done

    # Add end line
    echo "" >> "${FILE}"

    # Replace @ variables
    cat "${FILE}" | while read LINE
    do
        OLD_IFS=${IFS}
        IFS="@"
        for WORD in ${LINE}; do
            IFS=${OLD_IFS}
            WORD="@${WORD}"
            WORD=$(echo "${WORD}" | grep -o "@{.*}")
            RLINE=$(echo "${WORD}" | sed "s/@/\$/g")
            VALUE=$(eval "echo \"${RLINE}\"")
            if [ ! "${VALUE}" == "" ]; then

                replaceVariable()(
                    if [ "$(echo "${VALUE}" | grep "${1}")" == "" ]; then
                        sed -i "s${1}${WORD}${1}${VALUE}${1}g" "${FILE}"
                        exit 0
                    else
                        exit -1
                    fi
                )

                # Replace using non-used delimiter
                #for DEL in $(printf "$(printf '\\x %% x ' {32..126})")
                for DEL in "#" "|" "/" "*" "_" "+" "?" "-" "<" ">" ":" "." ";" "^"
                do
                    if replaceVariable "${DEL}"; then
                        REPLACED="True"
                        break
                    fi
                done
                if [ "$REPLACED" == "" ]; then
                    echo "${ERROR_COLOR} Can't replace ${WORD} with ${VALUE} ${REMOVE_FORMAT}"
                    exit -1
                fi
            fi
            IFS="@"
        done
        IFS=${OLD_IFS}
    done
    if [ $? -ne 0 ]; then
        exit -1
    fi
}

buildStep(){

    mv "${EXEC_PATH}" "${CURRENT_WORKING_PATH}"

    cd "${CURRENT_WORKING_PATH}"
    chmod u+x "${EXEC_FILE}"

    # exec
    (
        for SOURCE_FILE in $(cd / && find $BUILD_SOURCE_DIR -type f 2>/dev/null | sort); do
            source "${SOURCE_FILE}"
        done
        set -x
        . "${EXEC_FILE}" 2>&1
    ) 2>/dev/null | while read line; do echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${TRACE_COLOR} ${line} ${REMOVE_FORMAT}"; done;
    RESULT="$?"
    if [ ${RESULT} -ne 0 ]; then
        echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${ERROR_COLOR} Error(${RESULT})! ${REMOVE_FORMAT}"
        exit -1
    else
        echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${SUCCESS_COLOR} Done! ${REMOVE_FORMAT}"
        mv "${CURRENT_WORKING_PATH}" "${EXEC_PATH}"
        exit 0
    fi
}

buildSource(){

    mkdir -p "${BUILD_SOURCE_DIR}"

    BUILD_SOURCE_NAME=$(($(ls -1 ${BUILD_SOURCE_DIR} | wc -l) + 1))
    if [ ${BUILD_SOURCE_NAME} -lt 10 ]; then
        BUILD_SOURCE_NAME="000${BUILD_SOURCE_NAME}"
    elif [ ${BUILD_SOURCE_NAME} -lt 100 ]; then
        BUILD_SOURCE_NAME="00${BUILD_SOURCE_NAME}"
    elif [ ${BUILD_SOURCE_NAME} -lt 1000 ]; then
        BUILD_SOURCE_NAME="0${BUILD_SOURCE_NAME}"
    fi

    # Repace variables
    replaceVariables "${FILE}"

    # Copiar
    cp "${FILE}" "${BUILD_SOURCE_DIR}/${BUILD_SOURCE_NAME}"

    # Probar
    (
        echo "Testing ${FILE} -> ${BUILD_SOURCE_DIR}/${BUILD_SOURCE_NAME}"
        source "${BUILD_SOURCE_DIR}/${BUILD_SOURCE_NAME}"
    ) 2>/dev/null | while read line; do echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${TRACE_COLOR} ${line} ${REMOVE_FORMAT}"; done;
    RESULT="$?"
    if [ ${RESULT} -ne 0 ]; then
        echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${ERROR_COLOR} Error(${RESULT})! ${REMOVE_FORMAT}"
        exit -1
    else
        echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${SUCCESS_COLOR} Done! ${REMOVE_FORMAT}"
        exit 0
    fi
}

imageSource(){

    mkdir -p "${IMAGE_SOURCE_DIR}"
    mkdir -p "${BUILD_SOURCE_DIR}"

    IMAGE_SOURCE_NAME=$(($(ls -1 ${IMAGE_SOURCE_DIR} | wc -l) + 1))
    if [ ${IMAGE_SOURCE_NAME} -lt 10 ]; then
        IMAGE_SOURCE_NAME="000${IMAGE_SOURCE_NAME}"
    elif [ ${IMAGE_SOURCE_NAME} -lt 100 ]; then
        IMAGE_SOURCE_NAME="00${IMAGE_SOURCE_NAME}"
    elif [ ${IMAGE_SOURCE_NAME} -lt 1000 ]; then
        IMAGE_SOURCE_NAME="0${IMAGE_SOURCE_NAME}"
    fi
    BUILD_SOURCE_NAME=$(($(ls -1 ${BUILD_SOURCE_DIR} | wc -l) + 1))
    if [ ${BUILD_SOURCE_NAME} -lt 10 ]; then
        BUILD_SOURCE_NAME="000${BUILD_SOURCE_NAME}"
    elif [ ${BUILD_SOURCE_NAME} -lt 100 ]; then
        BUILD_SOURCE_NAME="00${BUILD_SOURCE_NAME}"
    elif [ ${BUILD_SOURCE_NAME} -lt 1000 ]; then
        BUILD_SOURCE_NAME="0${BUILD_SOURCE_NAME}"
    fi


    # Repace variables
    replaceVariables "${FILE}"

    # Copiar
    cp "${FILE}" "${IMAGE_SOURCE_DIR}/${IMAGE_SOURCE_NAME}"
    cp "${FILE}" "${BUILD_SOURCE_DIR}/${BUILD_SOURCE_NAME}"

    # Probar
    (
        echo "Testing ${FILE} -> ${BUILD_SOURCE_DIR}/${BUILD_SOURCE_NAME}"
        echo "Testing ${FILE} -> ${IMAGE_SOURCE_DIR}/${IMAGE_SOURCE_NAME}"
        source "${IMAGE_SOURCE_DIR}/${IMAGE_SOURCE_NAME}"
    ) 2>/dev/null | while read line; do echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${TRACE_COLOR} ${line} ${REMOVE_FORMAT}"; done;
    RESULT="$?"
    if [ ${RESULT} -ne 0 ]; then
        echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${ERROR_COLOR} Error(${RESULT})! ${REMOVE_FORMAT}"
        exit -1
    else
        echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${SUCCESS_COLOR} Done! ${REMOVE_FORMAT}"
        exit 0
    fi
}

entryPoint(){

    mkdir -p "${ENTRYPOINT_DIR}"

    ENTRYPOINT_NAME=$(($(ls -1 ${ENTRYPOINT_DIR} | wc -l) + 1))
    if [ ${ENTRYPOINT_NAME} -lt 10 ]; then
        ENTRYPOINT_NAME="000${ENTRYPOINT_NAME}"
    elif [ ${ENTRYPOINT_NAME} -lt 100 ]; then
        ENTRYPOINT_NAME="00${ENTRYPOINT_NAME}"
    elif [ ${ENTRYPOINT_NAME} -lt 1000 ]; then
        ENTRYPOINT_NAME="0${ENTRYPOINT_NAME}"
    fi

    # Repace variables
    replaceVariables "${FILE}"

    # Copiar
    cp "${FILE}" "${ENTRYPOINT_DIR}/${ENTRYPOINT_NAME}"
    chmod u+x "${ENTRYPOINT_DIR}/${ENTRYPOINT_NAME}"


    # No test
    echo "${LABEL_COLOR}[${REL_PATH}/${EXEC_FILE}]${SUCCESS_COLOR} Done! ${REMOVE_FORMAT}"
    exit 0
}

debugFile(){
    mkdir -p "${EXEC_PATH}"
    mv "${EXEC_PATH}" "${CURRENT_WORKING_PATH}"

    rm -rf ${IMAGE_SOURCE_DIR}

    ln -s ${BUILD_SOURCE_DIR} ${IMAGE_SOURCE_DIR}
    ln -s "%s/${EXEC_FILE}" "${CURRENT_WORKING_PATH}/${EXEC_FILE}"
}


case "$TYPE" in
    %s) buildStep ;;
    %s) buildSource ;;
    %s) imageSource ;;
    %s) entryPoint ;;
    %s) debugFile ;;
    *) exit -1 ;;
esac
''' % (image_working_dir, image_current_working_dir, image_bsource_folder, image_source_folder, image_entrypoint_folder, image_debug_folder,
    exec_extension, build_export_source_extension, image_export_source_extension, entrypoint_extension, debug_tag)


# Entrypoint script
run_entrypoint_script = '''#!/bin/bash

# Load sources
for SOURCE_FILE in $(cd / && find %s -type f 2>/dev/null | sort); do
    source "${SOURCE_FILE}"
done

# Load all entrypoints
for entrypoint_file in $(find %s -type f | sort); do
    $entrypoint_file &
done

bash

''' % (image_source_folder, image_entrypoint_folder)


# Log
class log:

    class mode:
        if is_windows:
            reset=''
            ireset=''
            bold=''
            disable=''
            underline=''
            reverse=''
            strikethrough=''
            invisible=''
        else:
            reset='\033[0m'
            ireset='\033[00m'
            bold='\033[01m'
            disable='\033[02m'
            underline='\033[04m'
            reverse='\033[07m'
            strikethrough='\033[09m'
            invisible='\033[08m'
    class fg:
        if is_windows:
            black=''
            red=''
            green=''
            orange=''
            blue=''
            purple=''
            cyan=''
            lightgrey=''
            darkgrey=''
            lightred=''
            lightgreen=''
            yellow=''
            lightblue=''
            pink=''
            lightcyan=''
        else:
            black='\033[30m'
            red='\033[31m'
            green='\033[32m'
            orange='\033[33m'
            blue='\033[34m'
            purple='\033[35m'
            cyan='\033[36m'
            lightgrey='\033[37m'
            darkgrey='\033[90m'
            lightred='\033[91m'
            lightgreen='\033[92m'
            yellow='\033[93m'
            lightblue='\033[94m'
            pink='\033[95m'
            lightcyan='\033[96m'
    class bg:
        if is_windows:
            black=''
            red=''
            green=''
            orange=''
            blue=''
            purple=''
            cyan=''
            lightgrey=''
        else:
            black='\033[40m'
            red='\033[41m'
            green='\033[42m'
            orange='\033[43m'
            blue='\033[44m'
            purple='\033[45m'
            cyan='\033[46m'
            lightgrey='\033[47m'

    def colorStr(color, string):
        return color + string.replace(log.mode.reset, log.mode.ireset + color) + log.mode.reset
    def trace(line):
        print(log.colorStr(log.fg.darkgrey, line))
    def error(line):
        print(log.colorStr(log.fg.red + log.mode.bold, line))
    def warning(line):
        print(log.colorStr(log.fg.yellow + log.mode.bold, line))
    def info(line):
        print(line)


# Image info
class image_info_t:
    name = str()
    tag = str()
    image_id = str()
    has_replace_tag = False
    image_from = list()
    not_found_image_from = list()
    direct_image_from = str()
    external_image_from = str()
    build_args = str()
    dockerfile_path = str()
    dockerfile_content = str()
    layers_files = list()

# Check filetype exts
def checkIfTypeFile(file, ext_list):

    for ext in ext_list:
        if file.endswith(ext):
            return True
    return False

# Check if image root folder
def checkIfDockerfileRoot(full_path):
    listOfFile = os.listdir(full_path)
    for file in listOfFile:
        if file.endswith(docker_file_name):
            return True
        for name in docker_file_name_list:
            if file.endswith(name):
                return True
    return False

# Get all files
def getDockerBuildFiles(dir_path):

    listOfFile = os.listdir(dir_path)
    allFiles = list()

    for entry in listOfFile:

        # ignore hidden files (linux)
        if entry.startswith('.'):
            continue

        # Get full path
        full_path = os.path.join(dir_path, entry)

        # Get nested dirs
        if os.path.isdir(full_path):
            if not checkIfDockerfileRoot(full_path):
                allFiles += getDockerBuildFiles(full_path)
        else:
            for files_extension in files_extensions:
                if entry.endswith(files_extension):
                    allFiles.append(full_path)
                    break


    return allFiles

# Convert to relative path
def relativePath(file_list, rel_path):
    rel_file_list=list()
    for path in file_list:
        rel_file_list.append(os.path.relpath(path, rel_path))
    return rel_file_list

# Escape linux chars
def escapeLinuxConsoleChars(string):
    string = string.replace(" ", "\ ")
    string = string.replace("&", "\&")
    string = string.replace("(", "\(")
    string = string.replace(")", "\)")
    string = string.replace("[", "\[")
    string = string.replace("]", "\]")
    return string

# Gen image name
def genImageBuildName(image_info, debug=False):
    final_image_name=image_info.name
    debug_string=""
    if debug:
        debug_string = "debug"

    def addTag(current_tag,tag):
        if tag == "":
            return current_tag
        elif current_tag == "":
            return tag
        else:
            return "%s_%s" % (current_tag, tag)

    final_tag=""
    final_tag=addTag(final_tag, image_info.tag)
    final_tag=addTag(final_tag, image_info.image_id)
    final_tag=addTag(final_tag, debug_string)
    if final_tag != "":
        final_image_name+=":%s" % (final_tag)
    return final_image_name

# Get imgage deps
def getImagesDeps(image_info, images_info):
    image_deps_list=list()
    image_deps_dup_list=list()
    image_info.not_found_image_from = list()

    # Add deps
    for image_dep in image_info.image_from:
        dep_found = False
        for image in images_info:
            if image_dep == genImageBuildName(image):
                image_deps_list += getImagesDeps(image, images_info)
                image_deps_list.append(image)
                dep_found = True
                break

        if dep_found == False:
            image_info.not_found_image_from.append(image_dep)

    # Clean duplications
    for image in image_deps_list:
        already_added = False
        for aux_image in image_deps_dup_list:
            if aux_image.name == genImageBuildName(image):
                already_added = True
                break
        if already_added == False:
            image_deps_dup_list.append(copy.deepcopy(image))

    return image_deps_dup_list

# Sort files
def sortFoundFiles(file_list):

    # Gen sort list
    sort_file_list = list()
    sort_file_enpoint_list = list()
    for build_file in file_list:
        file_name = os.path.basename(build_file)

        file_path = os.path.dirname(build_file)
        if checkIfTypeFile(file_name, source_file_extension_list):
            sort_full_path = os.path.join(file_path, sort_string2 + file_name)
        else:
            sort_full_path = os.path.join(file_path, sort_string + file_name)

        if checkIfTypeFile(file_name, entrypoint_extension_list):
            sort_file_enpoint_list.append(sort_full_path)
        else:
            sort_file_list.append(sort_full_path)

    # Sort
    sort_file_list.sort()
    sort_file_enpoint_list.sort()

    # Remove sort string
    file_list = list()
    for build_file in sort_file_list:
        file_list.append(build_file.replace(sort_string, "").replace(sort_string2, ""))
    for build_file in sort_file_enpoint_list:
        file_list.append(build_file.replace(sort_string, "").replace(sort_string2, ""))

    return file_list

# Get images
def getImagePaths(dir_path):

    listOfFile = os.listdir(dir_path)
    image_paths = list()

    for entry in listOfFile:

        # ignore hidden files (linux)
        if entry.startswith('.'):
            continue

        # Get full path
        full_path = os.path.join(dir_path, entry)

        # Get nested dirs
        if os.path.isdir(full_path):
            image_paths += getImagePaths(full_path)
        else:
            if entry.endswith(docker_file_name):
                image_paths.append(full_path)
            else:
                for name in docker_file_name_list:
                    if entry.endswith(name):
                        image_paths.append(full_path)
                        break

    return image_paths

# Create new dockerfile
def createNewDockerfile(folder_path):

    # Check if file exists
    if not os.path.isdir(folder_path):
        log.error("Can't create %s at %s. Directory does not exists." % (docker_file_name, folder_path))
        return -1


    # full path
    full_path = os.path.join(folder_path , docker_file_name)


    # Check if dockerfile already exits
    if os.path.isfile(full_path):
        log.error("Can't create %s. File already exists." % (full_path))
        return -1


    # Create dockerfile
    docker_file = open(full_path, "w")
    docker_file.write(docker_file_template)
    docker_file.close()
    log.info("Created new dockefile at %s." % full_path)


    # Check if already exits
    return 0

# Add file
def fileContentToEcho(file_content, file_path):
    echo = "rm -f %s" % (file_path)
    for line in file_content.splitlines():
        echo+= " && echo \"%s\" >> %s" % (line.replace("$", "\$"), file_path)
    return echo


# has to download checks
needToDownloadchecks = list()
def checkIfLocalURI(source):
    if source.uri.startswith("http://"):
        return False
    if source.uri.startswith("https://"):
        return False
    if source.uri.startswith("sftp://"):
        return False
    if source.uri.startswith("ftp://"):
        return False
    return True
needToDownloadchecks.append(checkIfLocalURI)
def checkLocalFileExits(source):
    if os.path.exists(os.path.join(source.image_path, source.file)):
        return True
    else:
        return False
needToDownloadchecks.append(checkLocalFileExits)
def checkLocalPartFileExits(source):
    for part_ext in source_part_extensions:
        files = glob.glob(os.path.join(source.image_path, source.file + "." + part_ext + "*"))
        if len(files) > 0:
            return True
    return False
needToDownloadchecks.append(checkLocalPartFileExits)


# dockerbuild layers
def addBuildTools(image_path):

    # Convert build script to dockerfile input
    script_lines = layer_build_script.split("\n")
    add_scrip_layer="mkdir -p %s && \\\n" % (Path(os.path.dirname(image_build_script)).as_posix())
    add_scrip_layer+="echo \"#!/bin/bash\" >> %s && \\\n" % (image_build_script)
    for line in script_lines:
        line = line.replace("\"", "\\\"")
        line = line.replace("$", "\$")
        add_scrip_layer+="echo \"%s\" >> %s && \\\n" % (line, image_build_script)
    add_scrip_layer+="echo \"\" >> %s" % (image_build_script)

    layer_lines = list()
    layer_lines.append("# Add required scripts ...")
    layer_lines.append("RUN %s" % (add_scrip_layer))
    layer_lines.append("RUN chmod u+x %s" % (image_build_script))
    return "\n".join(layer_lines) + "\n\n\n"

def getRequiedSources(image_path, file, root_dir, local_download):
    class source_t : pass

    current_image_working_dir = Path(image_working_dir + root_dir + "/").as_posix()

    # Read source data from file
    full_file_path = os.path.join(image_path, file)
    source_data_file = open(full_file_path, "r")
    source_list = list()
    for file_line in source_data_file:
        data = file_line.replace("\n", "").replace("\r", "").split(" ")
        source = source_t()
        source.uri=""
        source.file=""
        source.image_path=image_path
        for read_souce in data:
            if read_souce != "":
                if source.uri == "":
                    source.uri = read_souce
                else:
                    source.file = read_souce
                    break
        if source.file == "":
            source.file=os.path.join(os.path.dirname(file), re.sub(".*/", "", source.uri))
        else:
            source.file=os.path.join(os.path.dirname(file), source.file)

        source_list.append(source)
    source_data_file.close()

    # Check list
    layer_lines = list()
    layer_lines.append("# Required sources '%s'..." % file)
    for source in source_list:
        aux_local_download = local_download
        if not aux_local_download:
            for check in needToDownloadchecks:
                if check(source):
                    aux_local_download = True
                    break

        if aux_local_download:
            file_part_type = ""
            for part_ext in source_part_extensions:
                files = glob.glob(os.path.join(source.image_path, source.file + "." + part_ext + "*"))
                rel_path = os.path.dirname(source.file)
                part_files = ""
                for part_file in files:
                    file_name = os.path.basename(part_file)
                    file_rel_path = Path(os.path.join(rel_path, file_name)).as_posix()
                    part_files+="\"%s\", " % (file_rel_path)
                if part_files != "":
                    out_path=Path("%s/%s" % (current_image_working_dir, rel_path)).as_posix()
                    layer_lines.append("COPY [%s\"%s/\"]" % (part_files, out_path))
                    file_part_type=part_ext
                    break
            if file_part_type == "":
                out_path = Path("%s/%s" % (current_image_working_dir, source.file)).as_posix()
                source_path = Path(source.file).as_posix()
                layer_lines.append("COPY [\"%s\", \"%s\"]" % (source_path, out_path))
            else:
                out_path=Path("%s/%s" % (current_image_working_dir, source.file)).as_posix()
                layer_lines.append("RUN cat \"%s.%s\"* > \"%s\" && rm \"%s.%s\"*"
                    % (out_path, file_part_type, out_path, out_path, file_part_type))
        else:
            out_path=Path("%s/%s" % (current_image_working_dir, source.file)).as_posix()
            layer_lines.append("ADD [\"%s\", \"%s\"]" % (source.uri, out_path))

    return source_list, "\n".join(layer_lines) + "\n\n\n"

def addDebugStep(file, root_dir):

    file = Path(file).as_posix()
    root_dir = Path(root_dir).as_posix()
    current_image_working_dir = image_working_dir + "/" + root_dir
    working_path=Path("%s/%s" % (current_image_working_dir, os.path.dirname(file))).as_posix()

    layer_lines = list()
    layer_lines.append("# Build step '%s'..." % file)
    layer_lines.append("RUN mkdir -p \"%s\"" % (working_path))
    layer_lines.append("RUN %s %s \"%s\" \"%s\"" %
        (image_build_script, debug_tag, working_path, os.path.basename(file)))
    return "\n".join(layer_lines) + "\n\n\n"

def addBuildStep(file, root_dir):

    file = Path(file).as_posix()
    root_dir = Path(root_dir).as_posix()
    current_image_working_dir = Path(image_working_dir + root_dir + "/").as_posix()
    out_file=Path("%s/%s" % (current_image_working_dir, file)).as_posix()
    working_path=Path("%s/%s" % (current_image_working_dir, os.path.dirname(file))).as_posix()

    layer_lines = list()
    layer_lines.append("# Build step '%s'..." % file)
    layer_lines.append("COPY [\"%s\", \"%s\"]" % (file, out_file))
    layer_lines.append("RUN %s %s \"%s\" \"%s\"" %
        (image_build_script, exec_extension, working_path, os.path.basename(file)))
    return "\n".join(layer_lines) + "\n\n\n"

def addCleanWorkingDir(keep, image_name):
    layer_lines = list()
    layer_lines.append("# Add clean workspace ...")
    if not keep:
        layer_lines.append("RUN rm -rf %s" % (image_working_dir))

    return "\n".join(layer_lines) + "\n\n\n"

def addLoadEntrypointsScript():
    layer_lines = list()
    layer_lines.append("# Add Load all entrypoints script ...")
    layer_lines.append("RUN %s && chmod u+x %s" % (fileContentToEcho(run_entrypoint_script, image_entrypoint_file), image_entrypoint_file))

    return "\n".join(layer_lines) + "\n\n\n"

def addLoadEntrypoints():
    layer_lines = list()
    layer_lines.append("# Add Load all entrypoints ...")
    layer_lines.append("ENTRYPOINT [\"%s\"]" % (image_entrypoint_file))

    return "\n".join(layer_lines) + "\n\n\n"

def addEntrypoint(file, root_dir):

    file = Path(file).as_posix()
    root_dir = Path(root_dir).as_posix()
    current_image_working_dir = Path(image_working_dir + root_dir + "/").as_posix()
    out_file=Path("%s/%s" % (current_image_working_dir, file)).as_posix()
    working_path=Path("%s/%s" % (current_image_working_dir, os.path.dirname(file))).as_posix()

    layer_lines = list()
    layer_lines.append("# Entrypoint '%s'..." % file)
    layer_lines.append("COPY [\"%s\", \"%s\"]" % (file, out_file))
    layer_lines.append("RUN %s %s \"%s\" \"%s\"" %
        (image_build_script, entrypoint_extension, working_path, os.path.basename(file)))
    return "\n".join(layer_lines) + "\n\n\n"

def addRawAppend(image_path, file):

    # Read raw data from file
    full_file_path = os.path.join(image_path, file)
    source_data_file = open(full_file_path, "r")
    layer_lines = list()
    layer_lines.append("# Raw append '%s'..." % file)
    for file_line in source_data_file:
        layer_lines.append(file_line)
    return "\n".join(layer_lines) + "\n\n\n"

def addBuildSource(file, root_dir):

    file = Path(file).as_posix()
    root_dir = Path(root_dir).as_posix()
    current_image_working_dir = Path(image_working_dir + root_dir + "/").as_posix()
    out_file=Path("%s/%s" % (current_image_working_dir, file)).as_posix()
    working_path=Path("%s/%s" % (current_image_working_dir, os.path.dirname(file))).as_posix()

    layer_lines = list()
    layer_lines.append("# Build source '%s'..." % file)
    layer_lines.append("COPY [\"%s\", \"%s\"]" % (file, out_file))
    layer_lines.append("RUN %s %s \"%s\" \"%s\"" %
        (image_build_script, build_export_source_extension, working_path, os.path.basename(file)))
    return "\n".join(layer_lines) + "\n\n\n"

def addLoadImageSource():

    layer_lines = list()
    layer_lines.append("# Add Load image source ...")
    layer_lines.append("RUN echo \"for source_file in \$(find -L %s -type f 2> /dev/null | sort); do source \$source_file; done\" >> /etc/bash.bashrc" % (image_source_folder))

    return "\n".join(layer_lines) + "\n\n\n"

def addImageSource(file, root_dir):

    file = Path(file).as_posix()
    root_dir = Path(root_dir).as_posix()
    current_image_working_dir = Path(image_working_dir + root_dir + "/").as_posix()
    out_file=Path("%s/%s" % (current_image_working_dir, file)).as_posix()
    working_path=Path("%s/%s" % (current_image_working_dir, os.path.dirname(file))).as_posix()

    layer_lines = list()
    layer_lines.append("# Build source '%s'..." % file)
    layer_lines.append("COPY [\"%s\", \"%s\"]" % (file, out_file))
    layer_lines.append("RUN %s %s \"%s\" \"%s\"" %
        (image_build_script, image_export_source_extension, working_path, os.path.basename(file)))
    return "\n".join(layer_lines) + "\n\n\n"


# Main function
def main(argv=sys.argv[1:]):

    # Parse args
    parser = argparse.ArgumentParser(
        description=gen_description,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        '--dry-build',
        required=False,
        default="",
        action="store_true",
        help='Only display build files order')
    parser.add_argument(
        '--display-full-path',
        required=False,
        default="",
        action="store_true",
        help='Disblay full path')
    parser.add_argument(
        '--debug',
        metavar="['%s' path]" % exec_extension,
        required=False,
        default="",
        help='Debug at FILE')
    parser.add_argument(
        '--main-path',
        metavar = "[PATH]",
        required=False,
        default=os.getcwd(),
        help='Debug at FILE')
    parser.add_argument(
        '--keep-tmp-files',
        required=False,
        action="store_true",
        help='Dont remove temporal files')
    parser.add_argument(
        '--download-in-local',
        required=False,
        action="store_true",
        help='Download source in local dir')
    parser.add_argument(
        '--gen-dockerfile',
        metavar = "FILE_NAME",
        required=False,
        nargs='?',
        const="",
        help='Generate dockerfile')
    parser.add_argument(
        '--create-new-dockerfile',
        metavar = "PATH",
        required=False,
        nargs='?',
        const=os.getcwd(),
        help='Create new dockerfile')
    parser.add_argument(
        '--docker-build-args',
        metavar = "ARGS",
        required=False,
        default="",
        nargs='?',
        help='Docker build command args')
    parser.add_argument(
        '--source-part',
        metavar = "EXTENSIONS",
        required=False,
        nargs='+',
        help='Source part extensions')
    parser.add_argument(
        '--docker-build-files',
        metavar = "PATHS",
        required=False,
        nargs='+',
        help='Paths of the docker build files')
    args = parser.parse_args(argv)


    # Create base dockerfile and exit
    if args.create_new_dockerfile is not None:
        return createNewDockerfile(args.create_new_dockerfile)

    # Update file part size
    if args.source_part is not None:
        global source_part_extensions 
        source_part_extensions+=args.source_part


    # Check paths
    if args.docker_build_files is not None:
        abs_main_path = os.path.abspath(args.main_path)
        for docker_build_file in args.docker_build_files:
            abs_docker_build_file = os.path.abspath(docker_build_file)
            if not abs_docker_build_file.startswith(abs_main_path):
                log.error("Invalid given docker build path")
                return -1

    # Find images
    docker_images_path = getImagePaths(args.main_path)
    docker_images_path = sortFoundFiles(docker_images_path)


    # Get images info
    images_info = list()
    for docker_file_path in docker_images_path:

        # Init data
        image_info = image_info_t()
        image_info.image_from = list()
        image_info.dockerfile_path = docker_file_path


        # Read data from file
        docker_file = open(docker_file_path, "r")
        for file_line in docker_file:

            # Apend
            image_info.dockerfile_content += file_line

            # Clean
            file_line = file_line.replace("\n", "")
            file_line = file_line.replace("\r", "")

            # Get from
            if file_line.startswith(image_from_tag):
                image_info.image_from.append(file_line.replace(image_from_tag, "").lower())

            # Get image name
            elif file_line.startswith(image_name_tag):
                image_full_name = file_line.replace(image_name_tag, "")
                if ":" in image_full_name:
                    image_info.name = re.sub(":.*", "", image_full_name)
                    image_info.tag = re.sub(".*:", "", image_full_name)
                else:
                    image_info.name = image_full_name
                    image_info.tag = ""

            # Check if DockerBuild file
            elif file_line == image_generate_code_tag:
                image_info.has_replace_tag=True

            # Get docker build args
            elif file_line.startswith(image_build_args_tag):
                image_info.build_args=file_line.replace(image_build_args_tag, "")

        docker_file.close()


        # Checks
        if image_info.name == "":
            log.error("Missing image name for '%s'" % docker_file_path)
            return -1
        else:
            image_info.name = image_info.name.lower()


        # Get build files
        docker_build_files = getDockerBuildFiles(os.path.dirname(docker_file_path))
        image_info.layers_files = relativePath(sortFoundFiles(docker_build_files), os.path.dirname(docker_file_path))

        # Save data
        if image_info.has_replace_tag:
            images_info.append(image_info)


    # Get images
    images_to_build = list()
    for image_info in images_info:
        is_main_image = False
        if args.docker_build_files is not None:
            dockerfile_abs_path = os.path.abspath(image_info.dockerfile_path)
            for docker_build_file in args.docker_build_files:
                abs_docker_build_file = os.path.abspath(docker_build_file)
                if dockerfile_abs_path == abs_docker_build_file:
                    is_main_image = True
                    break
        elif os.path.dirname(image_info.dockerfile_path) == args.main_path:
            is_main_image = True

        if is_main_image:
            nested_images_to_build = list()
            nested_images_to_build += getImagesDeps(image_info, images_info)
            nested_images_to_build.append(copy.deepcopy(image_info))
            images_to_build.append(nested_images_to_build)


    # Calculate direct dep and external dep
    for image_to_build in images_to_build:
        external_Dep = ""
        last_dep = ""
        hash_calculation = ""
        for image_info in image_to_build:
            if external_Dep == "":
                if len(image_info.image_from) != 1:
                    log.error("From Image not found for '%s'" % (image_info.dockerfile_path))
                    return -1
                hash_calculation = image_info.image_from[0]
                h = blake2b(digest_size=4)
                h.update(bytes(hash_calculation, 'utf-8'))
                image_info.image_id = h.hexdigest()
                external_Dep = image_info.image_from[0]
                image_info.direct_image_from = image_info.image_from[0]
                last_dep = genImageBuildName(image_info)
            else:
                image_info.direct_image_from = last_dep
                h = blake2b(digest_size=4)
                h.update(bytes(hash_calculation, 'utf-8'))
                image_info.image_id = h.hexdigest()
                last_dep = genImageBuildName(image_info)

            hash_calculation += image_info.name
            image_info.external_image_from = external_Dep

        image_to_build[len(image_to_build)-1].image_id = ""

    # Build images
    for image_to_build in images_to_build:
        load_souce_layer_added = False
        Add_entrypoint_script = False
        debug_file = ""
        for image_info in image_to_build:

            # Display image info
            log.info("\nImage: %s (%s) from %s (%s)" % (log.colorStr(log.fg.green, genImageBuildName(image_info)), log.colorStr(log.fg.green, image_info.dockerfile_path),
                    log.colorStr(log.fg.green, image_info.direct_image_from), log.colorStr(log.fg.green, image_info.external_image_from)))

            # Check if missing dep
            if len(image_info.not_found_image_from) > 0 and image_info.not_found_image_from[0] != image_info.external_image_from:
                log.error("Dependency not found '%s' in '%s' " % (image_info.not_found_image_from, image_info.dockerfile_path))
                return -1

            # Include build tools scripts
            docker_file_content=addBuildTools(os.path.dirname(image_info.dockerfile_path))
            sources_to_download=list()
            for docker_build_file in image_info.layers_files:

                file_name = os.path.basename(docker_build_file)
                full_path = os.path.join(os.path.dirname(image_info.dockerfile_path), docker_build_file)
                image_current_folder=genImageBuildName(image_info)

                if args.display_full_path:
                    display_name = full_path
                else:
                    display_name = docker_build_file

                if os.path.abspath(args.debug) == full_path:
                    log.info("%s %s" % (log.colorStr(log.fg.yellow,
                                "[DEBUG STEP]   "), display_name))
                    docker_file_content += addDebugStep(docker_build_file, image_current_folder)
                    debug_file = full_path
                    if load_souce_layer_added == False:
                        load_souce_layer_added = True
                        docker_file_content += addLoadImageSource()
                    break


                if checkIfTypeFile(file_name, exec_extension_list):
                    log.info("%s %s" % (log.colorStr(log.fg.blue,
                                "[BUILD STEP]   "), display_name))
                    docker_file_content += addBuildStep(docker_build_file, image_current_folder)

                elif checkIfTypeFile(file_name, source_file_extension_list):
                    log.info("%s %s" % (log.colorStr(log.fg.lightred,
                                "[REQUIRED]     "), display_name))
                    source_list, aux_docker_file_content = getRequiedSources(os.path.dirname(image_info.dockerfile_path), docker_build_file, image_current_folder, args.download_in_local)
                    docker_file_content += aux_docker_file_content
                    sources_to_download += source_list
                    for source in source_list:
                        log.info("%s %s -> %s" % (log.colorStr(log.fg.lightred,
                            "[REQUIRED FILE]"), log.colorStr(log.fg.lightblue, source.uri), log.colorStr(log.fg.lightblue, source.file)))

                elif checkIfTypeFile(file_name, dokerfile_append_extension_list):
                    log.info("%s %s" % (log.colorStr(log.fg.purple,
                                "[RAW APPEND]   "), display_name))
                    docker_file_content += addRawAppend(os.path.dirname(image_info.dockerfile_path), docker_build_file)

                elif checkIfTypeFile(file_name, build_export_source_extension_list):
                    log.info("%s %s" % (log.colorStr(log.fg.cyan,
                                "[BUILD SOURCE] "), display_name))
                    docker_file_content += addBuildSource(docker_build_file, image_current_folder)

                elif checkIfTypeFile(file_name, image_export_source_extension_list):
                    log.info("%s %s" % (log.colorStr(log.fg.lightcyan,
                                "[IMAGE SOURCE] "), display_name))
                    if load_souce_layer_added == False:
                        load_souce_layer_added = True
                        docker_file_content += addLoadImageSource()
                    docker_file_content += addImageSource(docker_build_file, image_current_folder)

                elif checkIfTypeFile(file_name, entrypoint_extension_list):
                    log.info("%s %s" % (log.colorStr(log.fg.orange,
                                "[ENTRYPOINT]   "), display_name))
                    if Add_entrypoint_script == False:
                        Add_entrypoint_script = True
                        docker_file_content += addLoadEntrypointsScript()
                    docker_file_content += addEntrypoint(docker_build_file, image_current_folder)

                else:
                    log.warning("unknown file type '%s'" % docker_build_file)


            # Remplace generated content
            image_info.dockerfile_content = image_info.dockerfile_content.replace(image_generate_code_tag, docker_file_content)
            image_info.dockerfile_content = re.sub("%s.*\n" % image_from_tag, "", image_info.dockerfile_content)
            image_info.dockerfile_content = "%s %s\n\n%s\n\n" % (image_from_tag, image_info.direct_image_from, image_info.dockerfile_content)
            if Add_entrypoint_script:
                image_info.dockerfile_content += addLoadEntrypoints()
                image_info.dockerfile_content += "\n\n"
            if debug_file == "" :
                image_info.dockerfile_content += addCleanWorkingDir(args.keep_tmp_files, image_info.name)
                image_info.dockerfile_content += "\n\n"

            # Display generated dockerfile
            if args.gen_dockerfile is not None:

                # Get file name and path
                file_path = os.path.dirname(image_info.dockerfile_path)
                if args.gen_dockerfile == "":
                    file_name=genImageBuildName(image_info).replace(":", ".") + ".Dockerfile"
                else:
                    file_name=args.gen_dockerfile

                # Check file path
                if not os.path.isdir(file_path):
                    log.error("Can't create '%s' at '%s'. Directory does not exists." % (file_name, file_path))
                    return -1

                # Check if file exits
                #if os.path.isfile(os.path.join(file_path,file_name)):
                #    log.error("Can't create '%s' at '%s'. File exists." % (file_name, file_path))
                #    return -1


                # Create file
                open(os.path.join(file_path,file_name), 'w').write(image_info.dockerfile_content)
                continue


            # Exit if dry-build
            if args.dry_build:
                continue


            # Skip if docker is not installed
            if shutil.which("docker") is None:
                log.error("Cant build '%s'. Docker is not installed." % (genImageBuildName(image_info)))
                continue


            # Geneate file
            open(os.path.join(os.path.dirname(image_info.dockerfile_path), created_docker_file), 'w').write(image_info.dockerfile_content)


            # Download sources
            if args.download_in_local:
                for source in sources_to_download:
                    # Check if nee to be downloaded
                    download=True
                    for check in needToDownloadchecks:
                        if check(source):
                            download=False
                            break

                    # Download
                    if download:
                        log.trace("Downloading %s -> %s..." % (log.colorStr(log.fg.lightblue, source.uri), log.colorStr(log.fg.lightblue, source.file)))
                        download_file = requests.get(source.uri)
                        open(os.path.join(source.image_path, source.file), 'wb').write(download_file.content)


            # build build string
            final_image_name=genImageBuildName(image_info, debug_file != "")
            command_string = "docker build -t %s -f %s" % (final_image_name, created_docker_file)
            if image_info.build_args != "":
                command_string += image_info.build_args + " "
            if args.docker_build_args != "":
                command_string += args.docker_build_args + " "
            command_string += " ."


            # Build docker image
            if is_windows:
                cmd=["cmd", "/C", "%s" % command_string]
            else:
                cmd=["bash", "-c", "sudo %s" % command_string]
            p = subprocess.Popen(cmd, cwd=os.path.dirname(image_info.dockerfile_path))
            p.communicate()
            if p.returncode != 0:
                log.error("Error when building '%s'" % (image_info.dockerfile_path))
                return -1


            # Clean
            os.remove(os.path.join(os.path.dirname(image_info.dockerfile_path), created_docker_file))


            # Debug
            if debug_file != "" :
                cmd=["bash", "-c", "sudo docker run -it --rm --entrypoint bash -v %s:%s -w %s %s" %
                    (escapeLinuxConsoleChars(os.path.dirname(debug_file)), image_debug_folder, image_current_working_dir,
                    final_image_name)]
                p = subprocess.Popen(cmd, cwd=os.path.dirname(image_info.dockerfile_path))
                p.communicate()

                break

        # Break if debug
        if debug_file != "" :
            break


# Main execution
if __name__ == '__main__':
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        pass
