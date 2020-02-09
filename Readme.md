DockerBuild script is meant to help the docker build process. Is just a wrapper of the docker build process.
It will look for 'Dockerfile.sh', 'Dockerfile.buildExport.source' and 'Dockerfile.imageExport.source' files and add them to the docker image build steps sorting them by name and nesting level position.


# File description
  * Dockerfile.sh: shell script that will be executed in a docker build step. In order to debug it, change the file name to 'Dockerfile.debug.sh'.
  * Dockerfile.buildExport.source: Source file that will be included only in the build process.
  * Dockerfile.imageExport.source: Source file that will be included for the docker container execution and build process.


# DockerBuild.sh comand args help
    -D 	 Folder where Dockerfile is place. By default is the calling directory.
    -d 	 Folder where script will start the search of 'dockerfile.sh' files. This path can't be lower than the Dockerfile folder. By default is the Dockerfile folder.
    -a 	 docker build command args.


## Docker build command args help
        --add-host list           Add a custom host-to-IP mapping (host:ip)
        --build-arg list          Set build-time variables
        --cache-from strings      Images to consider as cache sources
        --cgroup-parent string    Optional parent cgroup for the container
        --compress                Compress the build context using gzip
        --cpu-period int          Limit the CPU CFS (Completely Fair Scheduler) period
        --cpu-quota int           Limit the CPU CFS (Completely Fair Scheduler) quota
    -c, --cpu-shares int          CPU shares (relative weight)
        --cpuset-cpus string      CPUs in which to allow execution (0-3, 0,1)
        --cpuset-mems string      MEMs in which to allow execution (0-3, 0,1)
        --disable-content-trust   Skip image verification (default true)
    -f, --file string             Name of the Dockerfile (Default is 'PATH/Dockerfile')
        --force-rm                Always remove intermediate containers
        --iidfile string          Write the image ID to the file
        --isolation string        Container isolation technology
        --label list              Set metadata for an image
    -m, --memory bytes            Memory limit
        --memory-swap bytes       Swap limit equal to memory plus swap: '-1' to enable unlimited swap
        --network string          Set the networking mode for the RUN instructions during build (default "default")
        --no-cache                Do not use cache when building the image
        --platform string         Set platform if server is multi-platform capable
        --pull                    Always attempt to pull a newer version of the image
    -q, --quiet                   Suppress the build output and print image ID on success
        --rm                      Remove intermediate containers after a successful build (default true)
        --security-opt strings    Security options
        --shm-size bytes          Size of /dev/shm
        --squash                  Squash newly built layers into a single new layer
        --stream                  Stream attaches to server to negotiate build context
        --target string           Set the target build stage to build.
        --ulimit ulimit           Ulimit options (default [])


