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
        author="Javier Moreno",
        author_email="jgmore@gmail.com",
        description="Docker image build tool",
        long_description_content_type="text/markdown",
        url="https://github.com/qeyup/DockerBuild",
    )
