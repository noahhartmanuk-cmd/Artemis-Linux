#!/bin/bash

#Passes through arguments such that the same installer can be used with different frontends

conf_file=$1

mapfile -t conf_file_arr < <(cat "$conf_file")

if ! [ "$?" -eq 0 ]; then
	exit 1
fi

rootpass=$2
userpass=$3

install_media=${conf_file_arr[0]} 
is_part=${conf_file_arr[1]}
disk=${conf_file_arr[2]}
tz_path=${conf_file_arr[3]}
locale=${conf_file_arr[4]}
username=${conf_file_arr[5]}
offensive=${conf_file_arr[6]}
hostname=${conf_file_arr[7]}

mapfile -t total_parts < <(lsblk "$install_media" --noheadings --output PATH)

for part in "${total_parts[@]}"; do
	mapfile -t mountpoints < <(findmnt --raw --noheadings -o TARGET "$part")
	for mountpoint in "${mountpoints[@]}"; do
		echo "$mountpoint"
		umount -R "$mountpoint"
	done
done

#Variables to edit to improve the experience
min_disk_size_bytes=$((1073741824*10)) #See bellow
efi_part_size_bytes=$((1073741824*1)) #Converts GiB to Bytes (change later if optimisations are needed)

efi_uuid=$(uuidgen) #Generates random uuids
root_uuid=$(uuidgen)

if [ "$is_part" -eq 1 ]; then

	if [[ "${install_media: -1:1}" =~ ^[0-9]*$ ]]; then #Devices ending in a number
		part_num=${install_media: -2:1} #Reads the penultimate character
	else
		part_num=${install_media: -1:1} #Reads the last character
	fi

	if ! part_start=$(lsblk -no START $install_media); then echo "part_start"; exit 1; fi #Gets the start of the partition then exits if that fails
	if ! part_size=$(lsblk -nbo SIZE $install_media); then echo "part_size"; exit 1; fi #Gets the size of the partition then exits if that fails
	part_end=$((part_start + (part_size / 512) - 1))

	if ! part_table_dump=$(sfdisk -d "$disk"); then #Dumps the disk partition into a variable
		echo "part_table_dump"
		exit 1
	fi

	if [[ -z $part_table_dump ]]; then
		echo "part_table_dump2"
		exit 1
	fi

	mapfile -t part_table <<< "$part_table_dump" #Converts the dump into a array which I can parse by itteration

	i=0 #Initialises variables
	found=0

	new_part_table=("${part_table[@]}") #Creates a new partition table from the OG this is so that the in case something goes wrong later down the road we can return to the original partition table althogh I have not added that feature yet

	install_media_prefix="$install_media :" #Can compare up to the colon on every line of the table such that e.g. /dev/sda1 doesn't match with /dev/sda10

	for entry in "${part_table[@]}"; do #Iterates over the array and trys to match the prefix created earlier with the start of the line of the partition table this is to that only the desired partition gets selected  
		if [[ "${entry:0:${#install_media_prefix}}" == "$install_media_prefix" ]]; then
			unset "new_part_table[$i]" #Deletes the corresponding line escencialy deleting the partition
			found=1 
		fi
		i=$((i + 1))
	done

	new_part_table=("${new_part_table[@]}") #Reindexes array after unset leaves gap

	if [ "$found" -eq 0 ]; then # Theoretically this shouldn't be needed but it stops the install process if the specified partition isn't in the spaecified disk
		exit 1 
	fi

	new_part_table+=(
		"start= $part_start, size= $((efi_part_size_bytes / 512)), type= C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid= $efi_uuid name=\"EFI system partition\""
		"start= $((part_start + (efi_part_size_bytes / 512))), size= $((part_size / 512 - (efi_part_size_bytes / 512))), type= 0fc63daf-8483-4772-8e79-3d69d8477de4, uuid= $root_uuid name=\"Gentoo/Artemis root partition\""
	)
	
	if ! (for line in "${new_part_table[@]}"; do
		printf "%s\n" "$line" 
	done) | sfdisk --no-reread "$disk"
	then
		exit 1
	fi


else
	if ! sfdisk --no-reread "$install_media" <<-EOF
	label: gpt
	start=, size=1G, type= C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid= $efi_uuid, name="EFI system partition"
	start=, size=, type= 0fc63daf-8483-4772-8e79-3d69d8477de4, uuid= $root_uuid, name="Gentoo/Artemis root partition"
	EOF
	then
		exit 1
	fi
fi

partprobe

efi_path=$(blkid -t "PARTUUID=$efi_uuid" -o device) #Yes ik I  do not need to do this but it does make debugging easier 
root_path=$(blkid -t "PARTUUID=$root_uuid" -o device)

echo "$efi_path"

yes | mkfs.vfat -F 32 "$efi_path"
yes | mkfs.ext4 "$root_path"

umount /mnt/Artemis/efi
umount -R /mnt/Artemis

rm -rf /tmp/artemisinstaller
rm -rf /mnt/Artemis/
rm -rf /mnt/Artemis/efi/

mkdir /mnt/Artemis
mount "$root_path" /mnt/Artemis/
if ! [ "$?" -eq 0 ]; then exit 1; fi
mkdir /mnt/Artemis/efi
mount "$efi_path" /mnt/Artemis/efi/
if ! [ "$?" -eq 0 ]; then exit 1; fi

i=0 

while

	ping -c 5 google.com >> /dev/zero

	if ! [ "$?" -eq 0 ]; then
		printf "No web connection! Disks Partitioned, possible data loss!"
		exit 2
	fi


	gpg --auto-key-locate=clear,nodefault,wkd --locate-key releng@gentoo.org

	if [ "$i" -gt 3 ]; then
		rm -rf /tmp/artemisinstaller/
		exit 1
	fi

	wget -r -q -nd -np -A '*' -P /tmp/artemisinstaller/ https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-openrc/

	mapfile -t files < <(ls -1 /tmp/artemisinstaller)

	found=0

	for file in "${files[@]}"; do
		if [[ "${file: -7:7}" == '.tar.xz' ]]; then
			version_id="$file"
			found=1
		fi
	done

	if [ "$found" -eq 0 ]; then 
		exit 1
	fi

	gpg --verify "/tmp/artemisinstaller/$version_id.asc" "/tmp/artemisinstaller/$version_id"
	verified=$?

	i+=1

	! [ "$verified" -eq 0 ]
do true; done

mv "/tmp/artemisinstaller/$version_id" /tmp/
rm -rf /tmp/artemisinstaller/

tar xpf "/tmp/$version_id" --xattrs-include='*.*' --numeric-owner -C /mnt/Artemis

rm "/tmp/$version_id"

cat <<EOF >> /mnt/Artemis/etc/portage/make.conf
USE="-systemd -grub -X -gnome -kde -plasma systemd-boot dist-kernel bluetooth pulseaudio wayland wifi usb $offensive"
ACCEPT_LICENSE="*"
EOF

cp --dereference /etc/resolv.conf /mnt/Artemis/etc/resolv.conf
cp /usr/local/bin/chrooted_setup /mnt/Artemis/usr/local/bin/chrooted_setup

mount --types proc /proc /mnt/Artemis/proc #Mounting any directories such that the kernel's jazz gets passed through
mount --rbind /sys /mnt/Artemis/sys
mount --make-rslave /mnt/Artemis/sys
mount --rbind /dev /mnt/Artemis/dev
mount --make-rslave /mnt/Artemis/dev
mount --bind /run /mnt/Artemis/run
mount --make-slave /mnt/Artemis/run 

#The next line is uncomneted because it has not been finished yet :)
chroot /mnt/Artemis /bin/bash -c "chmod +x /usr/local/bin/chrooted_setup && chrooted_setup $tz_path $locale" #Making file execuatable then using && to only attempt to run it if that works

rm /mnt/Artemis/usr/local/bin/chrooted_setup

echo "It also works!"

cat <<EOF > /mnt/Artemis/etc/fstab
# <file system> <mount point>  <type>  <options>       <dump>  <pass>
UUID=$efi_uuid     /efi          vfat   defaults         0 2
UUID=$root_uuid    /            ext4    defaults,noatime    0 1
EOF

echo $hostname > /mnt/Artemis/etc/hostname

mapfile -t mount_dir < <(findmnt "$root_dir" --raw -R -o TARGET)

done=1

mount_dir="${mountpoints[@]}"
prev_dir="$root_dir"

umount -R /mnt/Artemis