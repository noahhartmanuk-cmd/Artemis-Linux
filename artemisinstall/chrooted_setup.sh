timezone=$1
locale=$2

source /etc/profile

emerge-webrsync

dispatch-conf

yes | emerge --oneshot app-portage/cpuid2cpuflags 
if ! [ "$?" -eq 0 ]; then
    exit 2
fi
yes | emerge sys-kernel/linux-firmware
if ! [ "$?" -eq 0 ]; then
    exit 2
fi
yes | emerge sys-firmware/sof-firmware
if ! [ "$?" -eq 0 ]; then
    exit 2
fi

echo "$(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

ln -s "..$timezone" /etc/localtime

echo $locale >> /etc/locale.gen

locale-gen

echo "LANG=\"$locale\"" >> /etc/env.d/02locale

echo "It works!"

mkdir -p /etc/cmdline.d
ln -s /etc/kernel/cmdline /etc/cmdline.d/00-installkernel.conf

cat <<EOF > /etc/portage/package.use/systemd-boot
sys-apps/systemd boot
sys-apps/systemd-utils boot kernel-install
sys-kernel/installkernel systemd systemd-boot dracut
EOF

dispatch-conf

yes | emerge sys-kernel/installkernel
if ! [ "$?" -eq 0 ]; then
    exit 2
fi
yes | emerge sys-kernel/gentoo-kernel-bin

exit