```text
+------------------------------------------------------------+
|  █████╗ ██████╗ ████████╗███████╗███╗   ███╗██╗███████╗██╗ |
| ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝████╗ ████║██║██╔════╝██║ |
| ███████║██████╔╝   ██║   █████╗  ██╔████╔██║██║███████╗██║ |
| ██╔══██║██╔══██╗   ██║   ██╔══╝  ██║╚██╔╝██║██║╚════██║╚═╝ |
| ██║  ██║██║  ██║   ██║   ███████╗██║ ╚═╝ ██║██║███████║██╗ |
| ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝╚══════╝╚═╝ |
|                                                            |
|                                                            |
| The Linux distro for cool people!                          |
+------------------------------------------------------------+
```

```text
500]]]]0000]]0]W*+"  "+*d00]]]0000]]]]0]
?$$$$$$$$$$$$$L          !Z$$$$$$$$$$$$g
?$$$$$$$$$$$$#            '5$$$$$$$$$$$g
?$$$$$$$$$$$$/        `    r$$$$$$$$$$$g
?$$$$$$$$$$$$^`lc,  Clc*   !$$$$$$$$$$$g
?$$$$$$$$$$$$/L  4`_?  o'  -$$$$$$$$$$$g
?$$$$$$$$$$$$\ L;L**YLc*   -$$$$$$$$$$$g
?$$$$$$$$$$$$}'=l}C#4L+=    S$$$$$$$$$$g
?$$$$$$$$$$$$4 +":+:!+\L` ' 'd$$$$$$$$$g
?$$$$$$$$$$$V'_VL++\c?$N$`   'S$$$$$$$$g
?$$$$$$$$$$l ;NN$oo5NNNNN9     7$$$$$$$g
?$$$$$$$$V' -WNNN$NNWWAAZV\     _Z$$$$$g
?$$$$$$$H   rS$NN$NNNN$eo#?\     'S$$$$g
?$$$$$$$:  fNNNNNNNNNNNNNN$SL     '$$$$g
?$$$$$$4  ;NNNNN$NNNNNNNNNNNg`     c$$$g
?$$$$$?   RNNNNN9NNNNNNNNNNNN+     'N$$g
?$$$$V   +NNNNNNeNNNNNNNNNNNN^      S$$g
?$$$$} ` fNNNNNN5NNNNNNNNNNNN!      $$$g
?$$$$}L}l`+ZNNNNeNNNNNNNNNNL*!     +Z$$g
?LLL/l}}}L` =?gNNNNNNNNNN$?:L!   `;Lc$$g
f;}}}}}}}}L,  -dNNNNNNNNNH*!Ll+=+l}}LzAg
o!L}}}}}}}}}!`-SNNNNNNNNNY'_L}}c}}}}}}L7
f+}}}}}}}}}}L+?WNNNNNNW7"  _L}}}}}}Ll/:L
.+llLL}}}}}}}/` -::+!'     !L}}Ll+!_rC5g
ss*L\=":+lLLl:'+llLLll+!_` '!::!-!s$$$$g
SNNNNNNSsc+!_=?NNNNNNNNNNN$\_`-+?NNNNNNB
```

<img width="1180" height="918" alt="image" src="https://github.com/user-attachments/assets/a7675dcd-6168-4034-ae46-7e7797b6eb96" />


### Artemis-Linux

The start of my own gentoo-based desktop linux distro (It's the year of the linux desktop?)

I, whilst only being 14 have a decent amount of linux experience especially with Debian, Arch (btw) and more recently Gentoo albeit I am still lerning and this project may never well be perfect!

I have a lot of ambitions for this project and I will list them here, bear in mind this is by no means a solid project plan so take it with a heavy pinch of salt: 

* Once I have v1.0 finished and usable I want to start developing my own package manager that utilises Geismtoo's ebuild repositories such that once Artemis goes online it already has a solid collection of mantained packages

* Smart defaults: This is what the core philosophy of my distro will be, I will be using already amazing, open-source projects to make my distro work for example [Niri](https://github.com/niri-wm/niri), the scrolling window manager but my addition on top of this will be getting it to integrate perfectly with the other pieces of Artemis with practical and nice looking defaults

* Emphasis on the word *defaults*: I think that [Omarchy](https://omarchy.org/) does a lot of really cool and inovative aspects but I think that the options at install time are too minimal and may contribute to the 6GB! ISO file

* I want to make security a big focus on my distro without going too overboard, I want at least to have secure boot and disk encryption on by default, however I am interested in wireguard networks so I might see if I can make it easy to spin one up

* I want to write a unified settings application, such that you do not need to edit config files for each individual part of the system

* I want to have a plugin system so that people can add modules and configurations for the individual parts of the system all packaged into one easy to install package

I may not achieve all of these but I will hope th choose as many as possible!

## How to get started!

#### Ensure that you have basic GNU/Linux utilities installed such as `sfdisk`, `uuidgen`, and `gpg` as the program will not run without them

You test this by running it on a Linux system that has the correct and populated locale and timezone directories (such as the system I'm using, Manjaro) I know that this is far from ideal but I plan on making a more user-friendly experience soon! **This may not work in containerised services like docker, however it should work on a VM if you ensure that you pass through the block device that you are using**

This program, be warned is very slow, expect it to take up to an hour with a slow network and processor, this is due to the program doing a lot of compilation and downloading

#### Warning: Using this on a disk will erase data PERMANENTLY! 

* clone the directory with `git clone https://github.com/noahhartmanuk-cmd/Artemis-Linux`
* execute `cd ./Artemis-Linux/`
* Move the installer files to your `/usr/local/bin` directory with:
    ```bash
    cp ./artemisinstall/artemisinstall.sh /usr/local/bin/artemisinstall
    chmod +x /usr/local/bin/artemisinstall
    cp ./artemisinstall/artemisinstaller.sh /usr/local/bin/artemisinstaller
    chmod +x /usr/local/bin/artemisinstall 
    ```  
    (**you may need to run this as root depending on your system**) 

## How to use

The process is entirely interactive and it will prompt you to take the install step-by-step so due to that and the recent rapid development of the installer I will not take you through each step now but to start there are a few things you might want to look up before you decide to uninstall your current, insuperior OS:

* You will want to make note of the timezone that you are installing this in, there will be more advanced timezoning options in the future however, now, you will have to pick one
* You will also want to get your locale, it does a bunch of stuff that is usefull for a functioning OS
* There are other options but those are more up to personal preferance (if you want your hostname to be "notaramguzzler" you could!)

There are also some flags that you can run on `artemisinstall` however both of these are strongly advised against and may throw errors:

*  `--accept-loop-devices` shows loop devices in the device menu, this actually isn't that bad because there are some viable usecases (installing Artemis to a VM, testing...) in fact I use loop devices to test the latest versions of the installer but they can break your current install in some scenarios, so I have ommited them from the device list to avoid confusion
* `--no-use-root` bypasses the check that the script is being run as root and will ALMOST DEFINITELY make the installer throw errors and not install Artemis, I do not recommend that you run this even if you know what you are doing; it's just a waste of time

Enjoy!

Credit to [Harry's text2banner on github](https://github.com/harrylui1995/text2banner) which helped make the artemis banner and [kpberry's image to ascii](https://github.com/kpberry/image-to-ascii) for the tux ascii!
