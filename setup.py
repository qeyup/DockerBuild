#!/usr/bin/env python3


from DockerBuild import DockerBuild
import setuptools


entries = {'console_scripts': ['DockerBuild=DockerBuild.DockerBuild:main']}
packages = ['DockerBuild']
data_files = []


if __name__ == '__main__':
    setuptools.setup(
        name='DockerBuild',
        version=DockerBuild.version,
        packages=packages,
        entry_points=entries,
        data_files=data_files,
    )
