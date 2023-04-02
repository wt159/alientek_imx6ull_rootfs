# /bin/sh
# make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm menuconfig
rootfs="_install_rootfs"
compile_path="/usr/local/arm/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf/arm-linux-gnueabihf"
make
make install CONFIG_PREFIX=$rootfs

cd $rootfs
if [ ! -d proc ] && [ ! -d sys ] && [ ! -d dev ] && [ ! -d etc/init.d ] && [ ! -d tmp ] && [ ! -d lib ]; then
        mkdir proc sys dev tmp etc etc/init.d lib usr/lib
fi

if [ -f etc/init.d/rcS ]; then
        rm etc/init.d/rcS
fi
echo "#!/bin/sh" > etc/init.d/rcS
echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH" >> etc/init.d/rcS
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib" >> etc/init.d/rcS
echo "export PATH LD_LIBRARY_PATH" >> etc/init.d/rcS
echo "mount -a" >> etc/init.d/rcS
echo "mkdir /dev/pts" >> etc/init.d/rcS
echo "mount -t devpts devpts /dev/pts" >> etc/init.d/rcS
echo "echo /sbin/mdev > /proc/sys/kernel/hotplug" >> etc/init.d/rcS
echo "mount -t proc none /proc" >> etc/init.d/rcS
echo "mount -t sysfs none /sys" >> etc/init.d/rcS
echo "/sbin/mdev -s" >> etc/init.d/rcS
chmod +x etc/init.d/rcS

if [ -f etc/fstab ]; then
        rm etc/fstab
fi
echo "#<file system> <mount point> <type> <options> <dump> <pass>" >> etc/fstab
echo "proc /proc proc defaults 0 0" >> etc/fstab
echo "tmpfs /tmp tmpfs defaults 0 0" >> etc/fstab
echo "sysfs /sys sysfs defaults 0 0" >> etc/fstab

if [ -f etc/inittab ]; then
        rm etc/inittab
fi
echo "#etc/inittab" >> etc/inittab
echo "::sysinit:/etc/init.d/rcS" >> etc/inittab
echo "console::askfirst:-/bin/sh" >> etc/inittab
echo "::restart:/sbin/init" >> etc/inittab
echo "::ctrlaltdel:/sbin/reboot" >> etc/inittab
echo "::shutdown:/bin/umount -a -r" >> etc/inittab
echo "::shutdown:/sbin/swapoff -a" >> etc/inittab

if [ -f etc/resolv.conf ]; then
        rm etc/resolv.conf
fi
echo "nameserver 114.114.114.114" >> etc/resolv.conf
echo "nameserver 192.168.1.1" >> etc/resolv.conf

# cp lib
cp $compile_path/libc/lib/*so* lib/ -d
cp $compile_path/libc/lib/*.a lib/ 
rm lib/ld-linux-armhf.so*
cp $compile_path/libc/lib/ld-linux-armhf.so* lib/

cp $compile_path/lib/*so* lib/ -d
cp $compile_path/lib/*.a lib/ 

cp $compile_path/libc/usr/lib/*so* usr/lib/ -d
cp $compile_path/libc/usr/lib/*.a  usr/lib/

du ./lib ./usr/lib -sh

