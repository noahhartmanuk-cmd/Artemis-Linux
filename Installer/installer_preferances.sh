#!/bin/bash

read_only_num() {
    local prompt=$1
    local return_value=1
    local index=1
    while
        read -p "$prompt" return_value
        if [[ !($return_value =~ ^[1-9][0-9]*$) ]]; then
            printf "Please enter a valid number"
            for (( i=1; i<=index; i++)) do
                printf "(ㆆ_ㆆ)" #This is not a bug btw, this is my fruitless attempt at humor (ㆆ_ㆆ)
                local end=false
            done
            printf "\n"
        else 
            local end=true
        fi
        index=$(($index + 1))
        latest_num_return=$return_value

        [ $end == false ]
    do true; done
}

version_num="0.1"
latest_num_return=0
is_part=0
mapfile -t disks < <(lsblk --nodeps -noheadings --output PATH)

#Intro
printf "Welcome to the Artemis installer, the launchpad to Artemis linux!\nThis will now slowly guide you through the install process, step by step, without too much Gentoo jargon ദി(ᵔᗜᵔ)\n\n"

#Disk Selection/Partitioning
while
    
    printf "Type in the number of the disk that you want (if it is a partition that you want then you will get the option later\n"
    i=1

    for disk in "${disks[@]}"; do
        printf "%s: %s\n" "$i" "$disk"
        i=$((1+$i))
    done

    read_only_num "Number: "
    disk_num=$latest_num_return

    [ $disk_num -gt ${#disks[@]} ]
do true; done

if [ "$(lsblk "${disks[(($disk_num - 1))]}" --noheadings --output PATH | grep "^/dev/" | wc -l)" -gt 1 ]; then
    mapfile -t parts < <(lsblk "${disks[(($disk_num - 1))]}" --noheadings --output PATH)
    while 
        printf "Type the number of the partition you want to use\n"

        i=1

        for part in "${parts[@]}"; do
        printf "%s: %s\n" "$i" "$part"
        i=$((1+$i))
        done

        read_only_num "Number: "
        part_num=$latest_num_return
        is_part=1

        [ $part_num -gt ${#parts[@]} ]
    do true; done
fi

if [ "$is_part" -eq 1 ]; then
    install_media="${parts[(($part_num -1))]}"
else
    install_media="${disks[(($disk_num - 1))]}"
fi

printf "Are you sure you want to erase data and install Gentoo onto %s? (Y/n):" "$install_media"

read disk_check

if [[ "$disk_check" != "y" && "$disk_check" != "Y" ]]; then
    printf "Aborting Ascent..."
    exit 1
fi 

#Selecting Locales, TZ, Mirrors

mapfile -t zi_contents < <(ls /usr/share/zoneinfo/* -1d)

while
    i=1
 
    (printf "Find the index that your timezone is within, press q to exit less then type it into the prompt\n"
    for zi_dir in "${zi_contents[@]}"; do
        zi_name=${zi_dir#/usr/share/zoneinfo/}
        zi_name=${zi_name%/}
        printf "%s: %s\n" "$i" "$zi_name"
        i=$((i+1))
    done) | less

    read_only_num "What is your timezone's index: "
    tz_num=$latest_num_return

    [ $tz_num -gt "${#zi_contents[@]}" ]
do true; done

if [ -d "${zi_contents[(($tz_num - 1))]}" ]; then

    mapfile -t zi_group < <(ls -1 "${zi_contents[(($tz_num - 1))]}")
    
    while
        i=1
        
        (printf "You will now have the choice of which region you want within that area, find your index\npress q to exit less then type your index into the prompt\n"
        for tz in "${zi_group[@]}"; do
            tz_name=${tz#"${zi_contents[(($tz_num - 1))]}"}
            printf "%s: %s\n" "$i" "$tz_name"
            i=$(($i + 1))
        done) | less

        read_only_num "Timezone: "
        tz_sub_num=$latest_num_return

        tz_path="${zi_contents[(($tz_num -1))]}/${zi_group[((tz_sub_num -1))]}"

        [ $tz_sub_num -gt "${#zi_group[@]}" ]
    do true; done
else
    tz_path="${zi_contents[(($tz_num - 1))]}"
fi
printf "Your selected timezone was: %s\n" "$tz_path"

#Selecting Locales

mapfile -t avaliable_locales < <(cat /usr/share/i18n/SUPPORTED)

i=1

while 
    (printf "Find your index, press q then type your index into the prompt :Þ"
    for locale in "${avaliable_locales[@]}"; do
        printf "%s: %s\n" "$i" "$locale"
        i=$(($i + 1))
    done) | less
    read_only_num "Number: " locale_num
    locale_num=$latest_num_return

    [ $locale_num -gt "${#avaliable_locales[@]}" ]
do true; done

selected_locale="${avaliable_locales[(($locale_num - 1))]}"

printf "Your selected locale was: %s\n" "$selected_locale"

read -p "What do you want your hostname to be?: " hostname

while
    printf "What do you want the root password to be?:\n"
    read -s rootpass
    printf "Repeat, for safety : )\n"
    read -s rootpass_check
    [ $rootpass != $rootpass_check ]
do true; done

read -p "What do you want your username to be?: " username

while
    printf "What do you want %s's password to be?:\n" "$username"
    read -s userpass
    printf "Repeat, for safety : )\n"
    read -s userpass_check
    [ $userpass != $userpass_check ]
do true; done

read -p "What do you want the name in the bootloader to be?, I recomend 'Artemis :)'?: " bootloader_title

printf "You are going to install gentoo to %s\nYour timezone is %s\nYour locale is set to %s\nYour username is %s" "$install_media" "${tz_path#/usr/share/zoneinfo/}" "$selected_locale" "$username"

#Mirrorselect will be called later in the programme
./installer.sh 