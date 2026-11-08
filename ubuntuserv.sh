#!/bin/bash
set -e

# =========================
# CONFIGURATION
# =========================

VM_NAME="Ubuntuserveur26.1"

VBOXMANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
VBOXGUI="/c/Program Files/Oracle/VirtualBox/VirtualBox.exe"

VM_BASE="/c/Users/sevbo/VirtualBox VMs"
ISO="/c/Users/sevbo/Downloads/ubuntu-26.04-live-server-amd64.iso"

DISK_PATH="$VM_BASE/$VM_NAME/$VM_NAME.vdi"

echo "======================================"
echo "Étape 1 - Vérification VM existante"
echo "======================================"

if "$VBOXMANAGE" list vms | grep -q "\"$VM_NAME\""; then
    echo "VM existante détectée : $VM_NAME"

    echo "Choix :"
    echo "1) Supprimer complètement la VM"
    echo "2) Renommer la VM (non implémenté encore)"
    echo "3) Quitter"

    read -p "Votre choix : " choice

    if [ "$choice" = "1" ]; then
        echo "Suppression de la VM..."
        "$VBOXMANAGE" unregistervm "$VM_NAME" --delete
        echo "VM supprimée."
    else
        echo "Arrêt du script."
        exit 0
    fi
fi

echo "======================================"
echo "Étape 2 - Création VM"
echo "======================================"

"$VBOXMANAGE" createvm \
  --name "$VM_NAME" \
  --ostype "Ubuntu_64" \
  --register

echo "VM créée : $VM_NAME"

echo "======================================"
echo "Étape 3 - Configuration matériel"
echo "======================================"

"$VBOXMANAGE" modifyvm "$VM_NAME" \
  --memory 4096 \
  --cpus 2 \
  --ioapic on \
  --pae on \
  --nested-hw-virt on \
  --graphicscontroller vmsvga

echo "RAM / CPU / PAE / VT-x configurés"

echo "======================================"
echo "Étape 4 - Réseau"
echo "======================================"

# Adapter 1 NAT
"$VBOXMANAGE" modifyvm "$VM_NAME" \
  --nic1 nat \
  --nictype1 82540EM \
  --cableconnected1 on \
  --nicpromisc1 deny

# Adapter 2 Bridged
"$VBOXMANAGE" modifyvm "$VM_NAME" \
  --nic2 bridged \
  --bridgeadapter2 "Intel(R) Dual Band Wireless-AC 8260" \
  --nictype2 82540EM \
  --nicpromisc2 allow-all \
  --cableconnected2 on

# Adapter 3 Internal Network
"$VBOXMANAGE" modifyvm "$VM_NAME" \
  --nic3 intnet \
  --intnet3 "labo" \
  --nictype3 82540EM \
  --nicpromisc3 allow-all \
  --cableconnected3 on

echo "Réseau configuré"

echo "======================================"
echo "Étape 5 - Disque dur"
echo "======================================"

mkdir -p "$VM_BASE/$VM_NAME"

"$VBOXMANAGE" createmedium disk \
  --filename "$DISK_PATH" \
  --size 80000 \
  --format VDI

"$VBOXMANAGE" storagectl "$VM_NAME" \
  --name "SATA Controller" \
  --add sata \
  --controller IntelAhci

"$VBOXMANAGE" storageattach "$VM_NAME" \
  --storagectl "SATA Controller" \
  --port 0 \
  --device 0 \
  --type hdd \
  --medium "$DISK_PATH"

echo "Disque 80Go configuré"

echo "======================================"
echo "Étape 6 - ISO Ubuntu"
echo "======================================"

"$VBOXMANAGE" storagectl "$VM_NAME" \
  --name "IDE Controller" \
  --add ide

"$VBOXMANAGE" storageattach "$VM_NAME" \
  --storagectl "IDE Controller" \
  --port 0 \
  --device 0 \
  --type dvddrive \
  --medium "$ISO"

echo "ISO attaché : Ubuntu Server"

echo "======================================"
echo "Étape 7 - Démarrage VirtualBox"
echo "======================================"

start "" "$VBOXGUI"

echo "VirtualBox lancé"
echo "Script terminé."

