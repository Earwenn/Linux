#!/bin/bash

VM_NAME="LinuxMintVM"

ISO_PATH="C:\Users\sevbo\Downloads\linuxmint-22.3-cinnamon-64bit.iso"
# 👉 Chemin vers l’ISO Linux Mint (image d’installation)

VDI_PATH="/c/Users/$USERNAME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"
# 👉 Chemin où sera créé le disque dur virtuel de la VM

RAM=4096
# 👉 Mémoire RAM allouée à la VM (4 Go)

CPU=2
# 👉 Nombre de processeurs virtuels utilisés par la VM

DISK=51200
# 👉 Taille du disque virtuel en MB (50 Go)

echo "Création de la VM..."
# 👉 Affiche un message dans le terminal

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" createvm --name "$VM_NAME" --ostype Ubuntu_64 --register
# 👉 Crée la VM dans VirtualBox (type Ubuntu 64 bits compatible Linux Mint)

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" modifyvm "$VM_NAME" \
--memory $RAM \
--cpus $CPU \
--ioapic on \
--boot1 dvd \
--boot2 disk \
--boot3 none \
--boot4 none \
--hwvirtex on \
--nestedpaging on
#  Configure la VM :
# - RAM = 4096 MB
# - CPU = 2
# - Active contrôleur d’interruptions (ioapic)
# - Ordre de boot : DVD puis disque dur
# - Active virtualisation matérielle (VT-x / AMD-V)
# - Active optimisation mémoire (nested paging)

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" modifyvm "$VM_NAME" --nested-hw-virt on
# 👉 Active la virtualisation imbriquée (VT-x / AMD-V nested)

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" modifyvm "$VM_NAME" \
--vram 128 \
--graphicscontroller vmsvga
# 👉 Configure la carte graphique virtuelle

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" createmedium disk \
--filename "$VDI_PATH" \
--size $DISK \
--format VDI
# 👉 Crée un disque dur virtuel de 50 Go

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" storagectl "$VM_NAME" \
--name "SATA Controller" \
--add sata \
--controller IntelAhci
# 👉 Ajoute un contrôleur SATA (pour disque et ISO)

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" storageattach "$VM_NAME" \
--storagectl "SATA Controller" \
--port 0 \
--device 0 \
--type hdd \
--medium "$VDI_PATH"
# 👉 Branche le disque dur virtuel sur la VM

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" storageattach "$VM_NAME" \
--storagectl "SATA Controller" \
--port 1 \
--device 0 \
--type dvddrive \
--medium "$ISO_PATH"
# 👉 Branche l’ISO Linux Mint (comme un DVD d’installation)

"/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" modifyvm "$VM_NAME" --nic1 nat
# 👉 Configure le réseau en NAT (internet automatique)

echo "VM prête avec VT-x / AMD-V imbriqué activé !"
# 👉 Message final indiquant que la VM est prête