#!/usr/bin/env python3


from DockerBuild import DockerBuild
import setuptools


entries = {'console_scripts': ['DockerBuild=DockerBuild.DockerBuild:main']}
packages = ['DockerBuild']
data_files = []
install_requires=[
    'requests'
]
description=DockerBuild.short_description
long_description=DockerBuild.gen_description


if __name__ == '__main__':
    setuptools.setup(
        name='DockerBuild',
        version=DockerBuild.version,
        packages=packages,
        entry_points=entries,
        data_files=data_files,
        install_requires=install_requires,
        author="Javier Moreno",
        author_email="jgmore@gmail.com",
        description=description,
        long_description_content_type="text/markdown",
        long_description=long_description,
        url="https://github.com/qeyup/DockerBuild",
    )
