#!/bin/bash
# 👉 Utilise Bash pour exécuter le script

# =========================
# CONFIGURATION DE LA VM
# =========================
USERNAME="sevbo"
VM_NAME="FedoraVM26"
# 👉 Nom de la machine virtuelle

ISO_PATH="C:\Users\sevbo\Downloads\Fedora-Workstation-Live-44-1.7.x86_64.iso"
# 👉 Chemin vers l'image ISO Fedora
# ⚠️ Renomme ton ISO en "fedora.iso"

VDI_PATH="/c/Users/$USERNAME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"
# 👉 Emplacement du disque dur virtuel

RAM=4096
# 👉 4 Go de RAM

CPU=2
# 👉 2 processeurs virtuels

DISK=51200
# 👉 Disque dur virtuel de 50 Go

VBOX="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
# 👉 Chemin vers VBoxManage.exe

echo "Création de la VM Fedora..."
# 👉 Message affiché dans le terminal

# =========================
# CREATION DE LA VM
# =========================

"$VBOX" createvm \
--name "$VM_NAME" \
--ostype Fedora_64 \
--register

# 👉 Crée une VM Fedora 64 bits

# =========================
# CONFIGURATION CPU / RAM
# =========================

"$VBOX" modifyvm "$VM_NAME" \
--memory $RAM \
--cpus $CPU \
--ioapic on \
--boot1 dvd \
--boot2 disk \
--boot3 none \
--boot4 none \
--hwvirtex on \
--nestedpaging on

# 👉 Configure :
# - RAM
# - CPU
# - ordre de démarrage
# - VT-x / AMD-V
# - nested paging

# =========================
# VT-x / AMD-V IMBRIQUE
# =========================

"$VBOX" modifyvm "$VM_NAME" \
--nested-hw-virt on

# 👉 Active la virtualisation imbriquée

# =========================
# CONFIGURATION GRAPHIQUE
# =========================

"$VBOX" modifyvm "$VM_NAME" \
--vram 128 \
--graphicscontroller vmsvga

# 👉 Configure la carte graphique virtuelle

# =========================
# CREATION DISQUE VIRTUEL
# =========================

"$VBOX" createmedium disk \
--filename "$VDI_PATH" \
--size $DISK \
--format VDI

# 👉 Crée un disque VDI de 50 Go

# =========================
# CONTROLEUR SATA
# =========================

"$VBOX" storagectl "$VM_NAME" \
--name "SATA Controller" \
--add sata \
--controller IntelAhci

# 👉 Ajoute un contrôleur SATA

# =========================
# ATTACHEMENT DISQUE DUR
# =========================

"$VBOX" storageattach "$VM_NAME" \
--storagectl "SATA Controller" \
--port 0 \
--device 0 \
--type hdd \
--medium "$VDI_PATH"

# 👉 Branche le disque dur virtuel

# =========================
# ATTACHEMENT ISO FEDORA
# =========================

"$VBOX" storageattach "$VM_NAME" \
--storagectl "SATA Controller" \
--port 1 \
--device 0 \
--type dvddrive \
--medium "$ISO_PATH"

# 👉 Branche l’ISO Fedora comme DVD bootable

# =========================
# RESEAU
# =========================

"$VBOX" modifyvm "$VM_NAME" \
--nic1 nat

# 👉 Active internet en mode NAT

echo "VM Fedora prête avec VT-x / AMD-V imbriqué activé !"
# 👉 Message final