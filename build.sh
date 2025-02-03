#!/bin/sh
# Compile script for Teletubies kernel
# Copyright (c) Sijelek Malkist

PHONE="mido"
DEFCONFIG=teletubies_defconfig
COMPILERDIR="/home/clang"
CLANG="clang"
CODENAME="[New]"
ZIPNAME="Teletubies-$CODENAME-mido-$(date '+%Y%m%d-%H%M').zip"
CAPTION="Just Happy Compiler"

export KBUILD_BUILD_USER=malkist
export KBUILD_BUILD_HOST=android-server


# Header
cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"

echo -e "$cyan===========================\033[0m"
echo -e "$cyan= START COMPILING KERNEL  =\033[0m"
echo -e "$cyan===========================\033[0m"

echo -e "$blue...KSABAR...\033[0m"

echo -e -ne "$green== (10%)\r"
sleep 0.7
echo -e -ne "$green=====                     (33%)\r"
sleep 0.7
echo -e -ne "$green=============             (66%)\r"
sleep 0.7
echo -e -ne "$green=======================   (100%)\r"
echo -ne "\n"

echo -e -n "$yellow\033[104mPRESS ENTER TO CONTINUE\033[0m"
read P
echo  $P

# setup dir
WORK_DIR=$(pwd)
KERN_IMG="zImage"
KERN_IMG2="image.gz"

function clean() {
    echo -e "\n"
    echo -e "$red [!] CLEANING UP \\033[0m"
    echo -e "\n"
    rm -rf out
    make mrproper
}

elif [ "$TOOLCHAIN" == clang ]; then
	if [ ! -d "$HOME/proton_clang" ]
	then
		echo -e "$green << cloning proton clang >> \n $white"
		git clone --depth=1 https://gitlab.com/LeCmnGend/proton-clang -b clang-15 "$HOME"/proton_clang
	fi
	export PATH="$HOME/proton_clang/bin:$PATH"
	export STRIP="$HOME/proton_clang/aarch64-linux-gnu/bin/strip"

# Make Defconfig

function build_kernel() {
    export PATH="$COMPILERDIR/bin:$PATH"
    make -j$(nproc --all) O=out ARCH=arm64 ${DEFCONFIG}
    if [ $? -ne 0 ]
then
    echo -e "\n"
    echo -e "$red [!] BUILD FAILED \033[0m"
    echo -e "\n"
else
    echo -e "\n"
    echo -e "$green==================================\033[0m"
    echo -e "$green= [!] START BUILD ${DEFCONFIG}\033[0m"
    echo -e "$green==================================\033[0m"
    echo -e "\n"
fi

# Build Start Here

	make -j$(nproc --all) O=out \
                              ARCH=arm64 \
	                      CC="ccache clang" \
	                      AR=llvm-ar \
	                      NM=llvm-nm \
	                      STRIP=llvm-strip \
	                      OBJCOPY=llvm-objcopy \
	                      OBJDUMP=llvm-objdump \
	                      OBJSIZE=llvm-size \
	                      READELF=llvm-readelf \
	                      HOSTCC=clang \
	                      HOSTCXX=clang++ \
	                      HOSTAR=llvm-ar \
	                      CROSS_COMPILE=aarch64-linux-gnu- \
	                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	                      CONFIG_DEBUG_SECTION_MISMATCH=y \
	                      CONFIG_NO_ERROR_ON_MISMATCH=y   2>&1 | tee error.log
    
    # Zipping

    if [ -e "$KERN_IMG" ] || [ -e "$KERN_IMG2" ]; then
            echo -e "$green=============================================\033[0m"
            echo -e "$green= [+] Zipping up ...\033[0m"
            echo -e "$green=============================================\033[0m"
    if [ -d "$AK3_DIR" ]; then
            cp -r $AK3_DIR AnyKernel3
        elif ! git clone -q https://github.com/RapliVx/AnyKernel3.git -b vince; then
                echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
        fi
            cp $KERN_IMG AnyKernel3
            cd AnyKernel3
            git checkout vince &> /dev/null
            zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
            cd ..
            rm -rf AnyKernel3
    fi


    if [ -e "$KERN_IMG" ] || [ -e "$KERN_IMG2" ]; then
    echo -e "$green===========================\033[0m"
    echo -e "$green=  SUCCESS COMPILE KERNEL \033[0m"
    echo -e "$green=  Device     : $PHONE \033[0m"
    echo -e "$green=  Defconfig  : $DEFCONFIG \033[0m"
    echo -e "$green=  Toolchain  : $CLANG \033[0m"
    echo -e "$green=  Codename   : $CODENAME \033[0m"
    echo -e "$green=  New Driver : $ZIPNAME \033[0m"
    echo -e "$green=  Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) \033[0m "
    echo -e "$green=  Have A Brick Day Nihahahah \033[0m"
    echo -e "$green===========================\033[0m"
    else
    echo -e "$red [!] FIX YOUR KERNEL SOURCE BRUH !?\033[0m"
    fi

    if [ -e "$ZIPNAME" ] ; then 
    echo -e "$green=============================================\033[0m"
    echo -e "$green= [+] Uploading ...\033[0m"
    echo -e "$green=============================================\033[0m"
    # Ganti dengan nilai yang sesuai
    BOT_TOKEN="7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8"
    CHAT_ID="-1002287610863"

    # URL API Telegram untuk mengunggah file
    URL="https://api.telegram.org/bot$BOT_TOKEN/sendDocument"

    # Kirim file dengan keterangan
    curl -s -X POST "$URL" -F document=@"$ZIPNAME" -F caption="$CAPTION" -F chat_id="$CHAT_ID"

    fi
}

# execute
clean
build_kernel