#!/bin/bash

#Passes through arguments such that the same installer can be used with different frontends
install_media=$1 
is_part=$2
disk=$3
tz_path=$4
selected_locale=$5
rootpass=$6
username=$7
userpass=$8

#Variables to edit to improve the experience
min_disk_size_bytes=$((1073741824*10)) #See bellow
efi_part_size_bytes=$((1073741824*1)) #Converts GiB to Bytes (change later if optimisations are needed)

efi_uuid=$(uuidgen)
root_uuid=$(uuidgen)

if [ "$is_part" -eq 1 ]; then

	if [[ "${install_media:-1:1}" =~ ^[0-9]*$ ]]; then #Devices ending in a number
		part_num=${install_media: -2:1}
	else
		part_num=${install_media: -1:1}
	fi

	if ! part_start=$(lsblk -no START $install_media); then echo "part_start"; exit 1; fi
	if ! part_size=$(lsblk -nbo SIZE $install_media); then echo "part_size"; exit 1; fi
	part_end=$((part_start + (part_size / 512) - 1))

	if ! part_table_dump=$(sfdisk -d "$disk"); then
		echo "part_table_dump"
    	exit 1
	fi

	if [[ -z $part_table_dump ]]; then
		echo "part_table_dump2"
    	exit 1
	fi

mapfile -t part_table <<< "$part_table_dump"

	i=0
	found=0

	new_part_table=("${part_table[@]}")

	install_media_prefix=$("$install_media :") #Can compare up to the colon on every line of the table such that e.g. /dev/sda1 doesn't match with /dev/sda10

	for entry in "${part_table[@]}"; do
		if [[ ${entry:0:${#install_media_prefix}} == $install_media_prefix ]]; then
			unset "new_part_table[$i]"
			found=1
		fi
		i=$((i + 1))
	done

	new_part_table=("${new_part_table[@]}") #Reindexes array after unset leaves gap

	if [ "$found" -eq 0 ]; then #Theoretically this shouldn't be needed but it stops the install process if the specified partition isn't in the spaecified disk
		exit 1 
	fi

	new_part_table+=(
		"start= $part_start, size= $((efi_part_size_bytes / 512)), type= C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid= $efi_uuid name=\"EFI system partition\""
		"start= $((part_start + (efi_part_size_bytes / 512))), size= $((part_size / 512 - (efi_part_size_bytes / 512))), type= 0fc63daf-8483-4772-8e79-3d69d8477de4, uuid= $root_uuid name=\"Gentoo/Artemis root partition\""
		)
	
	if ! (for line in "${new_part_table[@]}"; do
		printf "%s\n" "$line" 
	done) | sfdisk "$disk"
	then
		exit 1
	fi

else
	if ! sfdisk "$install_media" <<-EOF
	label: gpt
	start=, size=1G, type= C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid= $efi_uuid, name="EFI system partition"
	start=, size=, type= 0fc63daf-8483-4772-8e79-3d69d8477de4, uuid= $root_uuid, name="Gentoo/Artemis root partition"
	EOF
	then
		exit 1
	fi
fi

efi_path=$(blkid -t "PARTUUID=$efi_uuid" -o device) #Yes ik I  do not need to do this but it does make debugging easier 
root_path=$(blkid -t "PARTUUID=$root_uuid" -o device)

echo $efi_path

yes | mkfs.vfat -F 32 "$efi_path"
yes | mkfs.ext4 "$root_path"

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

