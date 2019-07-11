# Build command

```bash
sudo docker build -t "$(basename $PWD | sed -e s/DockerBuild_//g):$(git branch | grep \* | sed -e s/'\* '//g | sed -e s/'\/'/-/g | sed -e s/@/__/g)" .
```


# Get all remotes

```bash
ls -1 | grep DockerBuild_ | while  read folder; do  ( cd $folder; git remote -v | grep fetch ); done

```

# update all submodules 

```bash
ls -1  | grep DockerBuild_ | while read folder
do
    (
        echo "\n- $folder -------------------------"
        cd $folder
        git ls-remote --heads origin | while read repo
        do 
            branch=$(echo $repo | sed -e s/'^.*heads\/'//g)
            echo "\n> Branch: $branch"
            git checkout $branch
            git clean -xffd && git submodule foreach --recursive git clean -xffd
            git submodule init
            git submodule update
            git submodule update --remote --recursive
            git status
            git add .
            git commit -m "Submodule update"
            git status
            echo "\n"
        done
    )
done

```


# Push all branches
```bash
ls -1  | grep DockerBuild_ | while read folder
do
    (
        echo "\n= $folder ==========================="
        cd $folder
        branches=$(git ls-remote --heads origin | while read repo; do repos="$(echo $repo | sed -e s/'^.*heads\/'//g) $repos"; done; echo $repos )
        bash -c "git push origin $branches"
    )
done

```

# Reset gitmodules

```bash
rm -f .git/index
git reset
```


# Load all submodules of a .gitmodules files

```bash
git config -f .gitmodules --get-regexp '^submodule\..*\.path$' | while read path_key dir_path
do
    name=$(echo $path_key | sed 's/\submodule\.\(.*\)\.path/\1/')
    url_key=$(echo $path_key | sed 's/\.path/.url/')
    branch_key=$(echo $path_key | sed 's/\.path/.branch/')
    url=$(git config -f .gitmodules --get "$url_key")
    branch=$(git config -f .gitmodules --get "$branch_key" || echo "master")
    git submodule add -b $branch --name $name $url $dir_path || continue
done
```


# Add submodules

```bash

NAME_REPO_BRANCH=(
     "zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/x86_64"
    "zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"
    "zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"
    "zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"

    "qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0@release_shared"
    "qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0@release_static"
    "qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0@debug_shared"
    "qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/x86_64@debug_shared"
    "qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/x86_64@release_shared"
    "qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/x86_64@release_static"
    "qt https://github.com/qeyup/DockerBuild_qt.git v5.12.2/ubuntu_v18.04/x86_64"

    "commtool https://github.com/qeyup/DockerBuild_comm-tools.git ubuntu_v18.04"

    "qpid-cpp v1.39.0/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_qpid-cpp.git"
    "qpid-cpp v1.39.0/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0 https://github.com/qeyup/DockerBuild_qpid-cpp.git"
    "qpid-cpp v1.39.0/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1 https://github.com/qeyup/DockerBuild_qpid-cpp.git"
    "qpid-cpp v1.39.0/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0 https://github.com/qeyup/DockerBuild_qpid-cpp.git"
    "qpid-cpp v1.38.0/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_qpid-cpp.git"

    "qpid-proton v0.27.0/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_qpid-proton.git"
    "qpid-proton v0.28.0/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0 https://github.com/qeyup/DockerBuild_qpid-proton.git"
    "qpid-proton v0.28.0/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1 https://github.com/qeyup/DockerBuild_qpid-proton.git"
    "qpid-proton v0.28.0/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0 https://github.com/qeyup/DockerBuild_qpid-proton.git"
    "qpid-proton v0.28.0/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_qpid-proton.git"

    "chrpath v0.16/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_chrpath.git"
    "chrpath v0.16/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0 https://github.com/qeyup/DockerBuild_chrpath.git"
    "chrpath v0.16/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0 https://github.com/qeyup/DockerBuild_chrpath.git"
    "chrpath v0.16/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1 https://github.com/qeyup/DockerBuild_chrpath.git"

    "toolchain arm-linux-gnueabi_v6.5.0/ubuntu_v18.04 https://github.com/qeyup/DockerBuild_linaro-toolchain.git"
    "toolchain arm-linux-gnueabihf_v6.5.0/ubuntu_v18.04 https://github.com/qeyup/DockerBuild_linaro-toolchain.git"
    "toolchain arm-linux-gnueabi_v7.4.1/ubuntu_v18.04 https://github.com/qeyup/DockerBuild_linaro-toolchain.git"

    "openssl v1.0.2r/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_openssl.git "
    "openssl v1.0.2r/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0 https://github.com/qeyup/DockerBuild_openssl.git"
    "openssl v1.0.2r/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1 https://github.com/qeyup/DockerBuild_openssl.git"
    "openssl v1.0.2r/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0 https://github.com/qeyup/DockerBuild_openssl.git"

    "curl v7.64.1/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_curl.git"
    "curl v7.64.1/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0 https://github.com/qeyup/DockerBuild_curl.git"
    "curl v7.64.1/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1 https://github.com/qeyup/DockerBuild_curl.git"
    "curl v7.64.1/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0 https://github.com/qeyup/DockerBuild_curl.git"

    "libtool v2.4.6/ubuntu_v18.04/x86_64 https://github.com/qeyup/DockerBuild_libtool.git"
    "libtool v2.4.6/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0 https://github.com/qeyup/DockerBuild_libtool.git"
    "libtool v2.4.6/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1 https://github.com/qeyup/DockerBuild_libtool.git"
    "libtool v2.4.6/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0 https://github.com/qeyup/DockerBuild_libtool.git"

    "custom https://github.com/qeyup/DockerBuild_custom.git ubuntu_v18.04"

    "gdpu-tool https://github.com/qeyup/DockerBuild_gdpu-tool.git ubuntu_v18.04"
)

for VAR in ${NAME_REPO_BRANCH[@]}
do
    eval "arr=($VAR)"
    NAME="${arr[1]}"
    REPO="${arr[2]}"
    BRANCH="${arr[3]}"
    FOLDER="$(echo ${NAME}_${BRANCH} | sed 's/[/]/__/g')"

    git submodule add -b ${BRANCH} ${REPO} ${FOLDER}
done

```
