#!/bin/bash

# Download the appropriate toolchain here:
# clang-r383902c 				https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/tags/platform-tools-31.0.0					Click clang-r383902c -> Click [tgz]
# aarch64-linux-android-4.9			https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+/refs/tags/platform-tools-31.0.0 		Click [tgz]

defconfig_folder=arch/arm64/configs
kernel_root=/mnt/e/Phone_Zf7Stuff/Kernel/StockKernel/kernel/msm-4.19
clang_path=/mnt/e/Phone_Zf7Stuff/Kernel/clang-r383902c
arm64_gcc_path=/mnt/e/Phone_Zf7Stuff/Kernel/aarch64-linux-android-4.9
kernel_output_path=out/arch/arm64/boot

mkdir -p out
export ARCH=arm64
export SUBARCH=arm64
export CLANG_PATH=$clang_path/bin
export PATH=${CLANG_PATH}:${PATH}
export DTC_EXT=$kernel_root/dtc-aosp
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$arm64_gcc_path/bin/aarch64-linux-android-

make CC=clang AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out -j$(nproc) "vendor/ZS670KS-perf_defconfig"

echo
echo "Build The Good Stuff"
echo 

time make CC=clang AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out -j$(nproc)

if [ -e $kernel_output_path/Image ]; then
	echo
	echo "Compress Kernel Image"
	echo 
	gzip -9 -k -f $kernel_output_path/Image
	echo
	echo "Compile DTBs"
	echo
	find $kernel_output_path/dts -name '*.dtb' -exec cat {} + > $kernel_output_path/dtb.img
	echo
	echo "Build Complete!"
	echo
else
	echo
	echo "Build Failed. See above error(s) for details."
	echo
fi
