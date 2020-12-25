usage: DockerBuild [-h] [--dry-build] [--display-full-path]
                   [--debug ['Dockerfile.sh' path]] [--main-path [PATH]]
                   [--keep-tmp-files] [--download-in-local] [--gen-dockerfile]
                   [--create-new-dockerfile [PATH]]
                   [--docker-build-args [ARGS]]
                   [--source-part EXTENSIONS [EXTENSIONS ...]]

DockerBuild v0.0.6. Util for docker build process.

Files types:

    - Sources: Source files to be downlaoded.
    - (*)Dockerfile.sh: shell script that will be executed in a docker build step.
    - (*)DockerfileAppend: Source file that will be included only in the build process.
    - (*)BuildExport: Source file that will be included to the docker container execution and build process. All @{*} variables will be replaced with the variable value.
    - (*)Entrypoint.sh: Entrypoint shell script.
    - (*)ImageExport: Append dockerfile raw layers.

optional arguments:
  -h, --help            show this help message and exit
  --dry-build           Only display build files order
  --display-full-path   Disblay full path
  --debug ['Dockerfile.sh' path]
                        Debug at FILE
  --main-path [PATH]    Debug at FILE
  --keep-tmp-files      Dont remove temporal files
  --download-in-local   Download source in local dir
  --gen-dockerfile      Display generated dockerfile
  --create-new-dockerfile [PATH]
                        Create new dockerfile
  --docker-build-args [ARGS]
                        Docker build command args
  --source-part EXTENSIONS [EXTENSIONS ...]
                        Source part extensions
