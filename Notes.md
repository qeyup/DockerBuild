# Build command

```bash
sudo docker build -t "$(basename $PWD | sed -e s/DockerBuild_//g):$(git branch | grep \* | sed -e s/'\* '//g | sed -e s/'\/'/-/g)" .
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