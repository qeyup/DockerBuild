# Add submodules to custom project

```bash

NAME_REPO_BRANCH=(
    # x86_64
    "1_zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/x86_64"
    "1_qpid-cpp https://github.com/qeyup/DockerBuild_qpid-cpp.git v1.39.0/ubuntu_v18.04/x86_64"
    "1_qpid-cpp https://github.com/qeyup/DockerBuild_qpid-cpp.git v1.38.0/ubuntu_v18.04/x86_64"
    "1_qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/x86_64@debug_shared"
    "1_qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/x86_64@release_shared"
    "1_qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/x86_64@release_static"
    #"1_qt https://github.com/qeyup/DockerBuild_qt.git v5.12.2/ubuntu_v18.04/x86_64"
    "1_qpid-proton https://github.com/qeyup/DockerBuild_qpid-proton.git v0.27.0/ubuntu_v18.04/x86_64"
    "1_qpid-proton https://github.com/qeyup/DockerBuild_qpid-proton.git v0.28.0/ubuntu_v18.04/x86_64"
    "1_chrpath https://github.com/qeyup/DockerBuild_chrpath.git v0.16/ubuntu_v18.04/x86_64"
    "1_openssl https://github.com/qeyup/DockerBuild_openssl.git v1.0.2r/ubuntu_v18.04/x86_64"
    "1_curl https://github.com/qeyup/DockerBuild_curl.git v7.64.1/ubuntu_v18.04/x86_64"
    "1_libtool https://github.com/qeyup/DockerBuild_libtool.git v2.4.6/ubuntu_v18.04/x86_64"

    # arm-linux-gnueabihf_v6.5.0
    "2_toolchain https://github.com/qeyup/DockerBuild_linaro-toolchain.git arm-linux-gnueabihf_v6.5.0/ubuntu_v18.04"
    "3_zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"
    "3_qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0@release_shared"
    "3_qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0@release_static"
    "3_qt https://github.com/qeyup/DockerBuild_qt.git v4.8.7/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0@debug_shared"
    "3_qpid-cpp https://github.com/qeyup/DockerBuild_qpid-cpp.git v1.39.0/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"
    "3_qpid-proton https://github.com/qeyup/DockerBuild_qpid-proton.git v0.28.0/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"
    "3_chrpath https://github.com/qeyup/DockerBuild_chrpath.git v0.16/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"
    "3_openssl https://github.com/qeyup/DockerBuild_openssl.git v1.0.2r/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"
    "3_curl https://github.com/qeyup/DockerBuild_curl.git v7.64.1/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"
    "3_libtool https://github.com/qeyup/DockerBuild_libtool.git v2.4.6/ubuntu_v18.04/arm-linux-gnueabihf_v6.5.0"

    # arm-linux-gnueabi_v6.5.0
    "4_toolchain https://github.com/qeyup/DockerBuild_linaro-toolchain.git arm-linux-gnueabi_v6.5.0/ubuntu_v18.04"
    "5_zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"
    "5_qpid-cpp https://github.com/qeyup/DockerBuild_qpid-cpp.git v1.39.0/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"
    "5_qpid-proton https://github.com/qeyup/DockerBuild_qpid-proton.git v0.28.0/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"
    "5_chrpath https://github.com/qeyup/DockerBuild_chrpath.git v0.16/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"
    "5_openssl https://github.com/qeyup/DockerBuild_openssl.git v1.0.2r/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"
    "5_curl https://github.com/qeyup/DockerBuild_curl.git v7.64.1/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"
    "5_libtool https://github.com/qeyup/DockerBuild_libtool.git v2.4.6/ubuntu_v18.04/arm-linux-gnueabi_v6.5.0"

    # arm-linux-gnueabi_v7.4.1
    "6_toolchain https://github.com/qeyup/DockerBuild_linaro-toolchain.git arm-linux-gnueabi_v7.4.1/ubuntu_v18.04"
    "7_zlib https://github.com/qeyup/DockerBuild_zlib.git v1.2.11/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"
    "7_qpid-cpp https://github.com/qeyup/DockerBuild_qpid-cpp.git v1.39.0/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"
    "7_qpid-proton https://github.com/qeyup/DockerBuild_qpid-proton.git v0.28.0/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"
    "7_chrpath https://github.com/qeyup/DockerBuild_chrpath.git v0.16/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"
    "7_openssl https://github.com/qeyup/DockerBuild_openssl.git v1.0.2r/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"
    "7_curl https://github.com/qeyup/DockerBuild_curl.git v7.64.1/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"
    "7_libtool https://github.com/qeyup/DockerBuild_libtool.git v2.4.6/ubuntu_v18.04/arm-linux-gnueabi_v7.4.1"

    # Multi
    "custom https://github.com/qeyup/DockerBuild_custom.git ubuntu_v18.04"
    "commtool https://github.com/qeyup/DockerBuild_comm-tools.git ubuntu_v18.04"
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

git submodule update --init --recursive

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

# Remove added modules

```bash
rm -f .gitmodules
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
