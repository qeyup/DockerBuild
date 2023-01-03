#!/bin/bash


# Update apt
apt update --fix-missing
apt upgrade -y


# Install apt packages
PACKAGES=()
PACKAGES+=(lxterminal)
PACKAGES+=(python3)
PACKAGES+=(python3-pip)
apt install -y ${PACKAGES[@]}


# Install pip3 packages
PACKAGES=()
PACKAGES+=(sdist)
PACKAGES+=(twine)
pip3 install ${PACKAGES[@]}

# Fix
pip3 install --upgrade keyrings.alt


# Create user
useradd --create-home --shell "/bin/bash" pypi_upload


# Create update script
cat >> /usr/bin/update.sh << EOF
#!/bin/bash
python3 setup.py sdist bdist_wheel 
twine upload dist/*
read
EOF
chmod a+x /usr/bin/update.sh
