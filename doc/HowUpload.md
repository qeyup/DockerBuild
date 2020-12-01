# Build docker image

1. Download (or update) DockerBuild

- **Download**

```bash
sudo -H pip3 install DockerBuild
```

- **Update**
```bash
sudo -H pip3 install --upgrade DockerBuild
```

1. Build docker image

```bash
cd ./docker
DockerBuild
```

1. Open container and update code

```bash
sudo docker run -it -v $PWD:/root/workspace pypi_upload
```

```docker
python3 setup.py sdist bdist_wheel
twine upload dist/*
```

# External links

[pypi packaging projects](https://packaging.python.org/tutorials/packaging-projects/)
