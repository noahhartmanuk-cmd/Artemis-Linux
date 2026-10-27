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
min_disk_size_bytes=$((1000000000*10)) #See bellow
efi_part_size_bytes=$((1000000000*1)) #Converts GiB to Bytes (change later if optimisations are needed)

if [ "$is_part" -eq 1 ]; then

	if [[ "${install_media:-1:1}" =~ ^[0-9]*$ ]]; then #Devices ending in a number
		part_num=${install_media: -2:1}
	else
		part_num=${install_media: -1:1}
	fi
	part_start=$(lsblk -no START $install_media)
	part_size=$(lsblk -nbo SIZE $install_media)
	part_end=$((part_start + (part_size / 512) - 1))

	mapfile -t part_table < <(sfdisk -d "$disk")

	i=0
	found=0

	new_part_table=("${part_table[@]}")

	for entry in "${part_table[@]}"; do
		if [[ ${entry:0:${#install_media}} == $install_media ]]; then
			unset "new_part_table[$i]"
			found=1
		fi
		i=$((i + 1))
	done

	new_part_table=("${new_part_table[@]}") #Reindexes array after unset leaves gap

	if [ "$found" -eq 0 ]; then
		exit 1
	fi

	new_part_table+=(
		"start= $part_start, size= $((efi_part_size_bytes / 512)), type= C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=11111111-1111-1111-1111-111111111111, name=\"EFI system partition\""
		"start= $((part_start + (efi_part_size_bytes / 512))), size= $((part_size / 512 - (efi_part_size_bytes / 512))), type= 0fc63daf-8483-4772-8e79-3d69d8477de4, uuid=22222222-2222-2222-2222-222222222222, name=\"Gentoo/Artemis root partition\""
		)
	
	(for line in "${new_part_table[@]}"; do
		printf "%s\n" "$line" 
	done) | sfdisk "$disk"
fi