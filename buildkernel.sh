#!/usr/bin/env sh

export LLVM=1
export LLVM_IAS=1

if [[! -f ".config" ]] ; then
    echo "Copied kernel config from /boot"
    cp /boot/mia.config ./.config
else
    echo "Kernel config found"
fi

echo "Preparing new kernel config"
make oldconfig

echo "Removing extraversion"
sed -i 's/EXTRAVERSION.*/EXTRAVERSION = /g' Makefile

echo "Preparing kernel modules"
make modules_prepare > /dev/null 2>&1
echo "Building kernel"
make -j14 > /dev/null 2>&1
echo "Installing modules"
make -j14 modules_install > /dev/null 2>&1
echo "Reinstalling DKMS modules"
FEATURES="-usersandbox" emerge @module-rebuild > /dev/null 2>&1
echo "Installing kernel to /boot"
cp /usr/src/linux/arch/x86/boot/bzImage /boot/mia.efi
echo "Getting kernel version"
KERNEL_VERSION=$(ls /lib/modules | sort -n -r | head -n 1)
echo "Regenerating initramfs"
dracut --force --kver=$KERNEL_VERSION /boot/initramfs-mia.img > /dev/null 2>&1
echo "Copying config to /boot"
cp /usr/src/linux/.config /boot/mia.config
