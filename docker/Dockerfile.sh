#!/bin/bash


# Update apt
apt update --fix-missing
apt upgrade -y


# Install apt packages
PACKAGES=()
PACKAGES+=(python3)
PACKAGES+=(python3-pip)
apt install -y ${PACKAGES[@]}


# Install pip3 packages
PACKAGES=()
PACKAGES+=(sdist)
PACKAGES+=(twine)
pip3 install ${PACKAGES[@]}
