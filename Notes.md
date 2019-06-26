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
