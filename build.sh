#!/usr/bin/env bash
#
# Build Script for Biofrost Kramel
# Copyright (C) 2022-2023 Mar Yvan D.
#

# MMDA Clearing Operation (anti re-send)
echo "Clearing Environment"
rm -rf $(pwd)/AnyKernel/*.zip
echo "Nuking zImage in AK3 Folder"
rm -rf $(pwd)/AnyKernel/zImage
echo "Nuking out Folder"
rm -rf $(pwd)/out
echo "Cleaning Completed."

echo "Cloning dependencies"
git clone --depth=1 -b clang-20.0 https://gitlab.com/kutemeikito/rastamod69-clang clang
git clone --depth=1 https://github.com/malkist01/anykernel.git -b master AnyKernel
echo "Done!"

# Default kernel directory.
KERNEL_DIR=$(pwd)

# Main
IMAGE=$(pwd)/out/arch/arm64/boot/zImage
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%s")
START=$(date +"%s")
PATH="${PWD}/clang/bin:$PATH"
export ARCH=arm64

# Default compiler directory.
CLANG_ROOTDIR=$(pwd)/clang

# Builder/Host.
export KBUILD_BUILD_USER="malkist"
export KBUILD_BUILD_HOST=android-server

# Compiler + Linker information.
CLANG="$(${CLANG_ROOTDIR}/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
LINKER_VERSION="$("${CLANG_ROOTDIR}"/bin/ld.bfd --version | head -n 1 | sed 's/(compatible with [^)]*)//' | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
export KBUILD_COMPILER_STRING="$($(pwd)/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

# Device name.
export DEVICE="Redmi note 4"

# Device codename.
export CODENAME="mido"

# Top Commit Information (commit hash).
COMMIT_HASH=$(git rev-parse --short HEAD)
export COMMIT_HASH

# Default device defconfig used.
DEVICE_DEFCONFIG=teletubies_defconfig

# Build Status.
BUILD_INFO=Experimental

# Telegram Information.
bot_token="7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8"

# Where to push? Set 1 for Private Testing Group, 0 for Personal
TESTING_GROUP=0

if [ "${TESTING_GROUP}" = 1 ]; then
    chat_id="-1002287610863"
else
    chat_id="-1002287610863"
fi

# Post Main Information
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/$bot_token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b> - Teletubies | Machine Build Triggered</b>%0A<b>Builder: </b><code>${KBUILD_BUILD_USER}</code>%0A<b>Date: </b><code>$(date)</code>%0A<b>Device: </b><code>${DEVICE} (${CODENAME})</code>%0A<b>Kernel Version: </b><code>$(make kernelversion 2>/dev/null)</code>%0A<b>Compiler: </b><code>${CLANG}</code>%0A<b>Linker: </b><code>${LINKER_VERSION}</code>%0A<b>Zip Name: </b><code>Biofrost-${CODENAME}-${DATE}</code>%0A<b>Build Status: </b><code>${BUILD_INFO}</code>%0A<b>Branch: </b><code>$(git rev-parse --abbrev-ref HEAD)</code><code>(master)</code>%0A<b>Top Commit: </b><a href='${REPO_URL}/commit/${COMMIT_HASH}'>${COMMIT_HASH}</a> <code>($(git log --pretty=format:'%s' -1))</code>"
}   
# Push Build to Channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/$bot_token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | <b>Compiled with: ${CLANG}+ ${LINKER_VERSION}.</b>"
}
# Error? Press F
function finerr() {
    curl -s -X POST "https://api.telegram.org/$bot_token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Build throw an error, please check the logs."
    exit 1
}
# Compile >.<
function compile() {
    make O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
    make -j$(nproc --all) O=out \
              PATH=${KERNEL_DIR}/clang/bin:${PATH} \
              ARCH=arm64 \
			  CC=clang \
              CLANG_TRIPLE=aarch64-linux-gnu- \
			  CROSS_COMPILE=aarch64-linux-gnu- \
			  CROSS_COMPILE_ARM32=arm-linux-gnueabi- 
	          AR=llvm-ar \  
	          AS=llvm-as \
              NM=llvm-nm \
              OBJCOPY=llvm-objcopy \
	          OBJDUMP=llvm-objdump \
              STRIP=llvm-strip \

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel

}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 Teletubies-${CODENAME}-${DATE}.zip *
    cd ..
}
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push