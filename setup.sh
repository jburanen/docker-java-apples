#!/bin/bash

JDK_FILE="jdk-8u202-linux-x64.tar.gz"
JDK_URL="https://mirrors.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz"
JDK_MD5="0029351f7a946f6c05b582100c7d45b7"

echo "Checking for JDK package..."

if [ ! -f "$JDK_FILE" ]; then
    echo "Downloading $JDK_FILE..."
    curl -O "$JDK_URL"
    if [ $? != 0 ]; then
        echo "Download failed. Could not fetch $JDK_FILE"
        exit 1
    fi
fi

echo "Verifying checksum..."
if command -v md5sum &>/dev/null; then
    md5=$(md5sum "$JDK_FILE" | awk '{print $1}')
else
    md5=$(md5 -q "$JDK_FILE")
fi

if [ "$md5" != "$JDK_MD5" ]; then
    echo "Checksum mismatch for $JDK_FILE — file may be corrupt. Delete it and re-run setup.sh."
    exit 1
fi

echo "JDK package verified."
echo ""
echo "Setup complete. Run the container with:"
echo "  docker-compose up --build"
