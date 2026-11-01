timezone=$1
locale=$2

source /etc/profile

emerge-webrsync

echo "$(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

ln -s "$timezone" /etc/localtime

echo "LANG=\"$locale\"" >> /etc/env.d/02locale


