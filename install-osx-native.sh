#!/bin/bash
depends_prefix="`pwd`/universal-apple-darwin"

sh build-osx-native.sh

install_prefix="$HOME/SDKs/KV"
if [ ! -z "${1}" ]; then
    install_prefix="${1}"
fi

echo "Installing to ${install_prefix}?"
echo "This is a destructive operation and cannot be undone, continue? (Y/n)"
read answer
if [ ${answer} = "y" ] || [ ${answer} = "Y" ]; then
    echo "Installing..."
    mkdir -p "${install_prefix}"
    rsync -ar --delete "${depends_prefix}/" "${install_prefix}/"
    for f in `find "${install_prefix}" -name "*.pc"`; do
        sed -i.bak "s@${depends_prefix}@${install_prefix}@g" "${f}"
    done
    find "${install_prefix}" -name "*.pc.bak" -delete
fi
