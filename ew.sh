#!/bin/sh

cd ~
git clone https://github.com/ondasd/for-disko
git clone https://github.com/ondasd/disko-setup
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
echo "--------------------------------------------------------"
echo "!DEFAULT DISK-/dev/sda!"
echo "--------------------------------------------------------"
echo "Need to format the disk?"
read -p "y/n: " qwe
case $qwe in
    Y|YES|YE|YS|y|yes|ye|ys)
        read -rp "disk: " asd
        wipefs -a /dev/"$asd"
        ;;
    N|NO|n|no)
        echo "ok"
    ;;
    *)
        echo "try again"
esac
echo "change?"
read -p "yes/no: " answer
case $answer in
    Y|YES|YE|ye|yes|y)
        read -rp "disk: " refer
        cd ~/disko-setup
        sed -i "6s|.*|        device = \"/dev/$refer\";|" disko-conf.nix
        ;;
    N|NO|n|no)
        echo "good"
        ;;
    *)
        echo "try again"
        ;;        
esac
cp  ~/disko-setup/disko-conf.nix /tmp/disko.nix
cd /tmp
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disko.nix
echo "work?"
echo "yes/no"
read -p ":" otvet
case $otvet in
    YES|YE|Y|yes|ye|y)
        echo "nice"
        ;;
    NO|N|n|no)
        nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disko.nix
        ;;
    *)
        echo "try again"
        ;;
esac
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
mkdir -p /mnt/etc/nixos
cp /tmp/disko.nix /mnt/etc/nixos/Disko.nix
cd /mnt/etc/nixos
nixos-generate-config --no-filesystems --root /mnt
cp ~/for-disko/configuration.nix /mnt/etc/nixos/configuration.nix
touch /mnt/etc/nixos/flake.nix
cp ~/for-disko/flake.nix /mnt/etc/nixos/flake.nix
nixos-install
sed '7c# "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"' configuration.nix
touch /mnt/etc/nixos/Home.nix
cp ~/for-disko/home.nix /mnt/etc/nixos/Home.nix
nixos-rebuild switch
cd ~
rm -rf for-disko
rm -rf disko-setup
rm -rf asf
