#!/usr/bin/env bash

# =========================================================
# Vérification Ubuntu Server + paquets Web
# Compatible Ubuntu 22.04 / 24.04
# =========================================================

set -e

# =========================================================
# Couleurs
# =========================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# =========================================================
# Liste des paquets
# =========================================================

REQUIRED_PACKAGES=(
  apache2
  php8.4-fpm
  mariadb-server
  php8.4-curl
  php8.4-gd
  php8.4-intl
  php8.4-mysql
  php8.4-zip
  php8.4-bcmath
  php8.4-mbstring
  php8.4-xml
  php8.4-bz2
  php8.4-imap
)

# =========================================================
# Vérification sudo
# =========================================================

if ! command -v sudo >/dev/null 2>&1; then
  echo -e "${RED}Erreur : sudo n'est pas installé.${NC}"
  exit 1
fi

# =========================================================
# Mise à jour des dépôts
# =========================================================

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE} Mise à jour des dépôts APT${NC}"
echo -e "${BLUE}=================================================${NC}"

sudo apt update

# =========================================================
# Vérification des mises à jour système
# =========================================================

echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE} Vérification des mises à jour système${NC}"
echo -e "${BLUE}=================================================${NC}"

UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing" || true)

if [ -z "$UPGRADABLE" ]; then

  echo -e "${GREEN}Le système est déjà à jour.${NC}"

else

  echo -e "${YELLOW}Des mises à jour sont disponibles :${NC}"
  echo "$UPGRADABLE"

  echo ""
  read -rp "Voulez-vous mettre à jour le système ? (o/N) : " UPDATE_SYSTEM

  if [[ "$UPDATE_SYSTEM" =~ ^[oO]$ ]]; then

    sudo apt upgrade -y
    sudo apt autoremove -y

    echo -e "${GREEN}Système mis à jour.${NC}"

  else

    echo -e "${YELLOW}Mise à jour ignorée.${NC}"

  fi

fi

# =========================================================
# Vérification des paquets
# =========================================================

echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE} Vérification des paquets requis${NC}"
echo -e "${BLUE}=================================================${NC}"

MISSING_PACKAGES=()

for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do

  echo ""

  if dpkg -s "$PACKAGE" >/dev/null 2>&1; then

    INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' "$PACKAGE")

    echo -e "${GREEN}[INSTALLÉ]${NC} $PACKAGE (${INSTALLED_VERSION})"

    CURRENT=$(apt-cache policy "$PACKAGE" | awk '/Installed:/ {print $2}')
    CANDIDATE=$(apt-cache policy "$PACKAGE" | awk '/Candidate:/ {print $2}')

    if [ "$CURRENT" != "$CANDIDATE" ]; then

      echo -e "${YELLOW}Mise à jour disponible :${NC}"
      echo "$CURRENT -> $CANDIDATE"

      read -rp "Mettre à jour $PACKAGE ? (o/N) : " UPDATE_PKG

      if [[ "$UPDATE_PKG" =~ ^[oO]$ ]]; then
        sudo apt install --only-upgrade -y "$PACKAGE"
      fi

    else

      echo -e "${GREEN}Déjà à jour.${NC}"

    fi

  else

    echo -e "${RED}[ABSENT]${NC} $PACKAGE"

    MISSING_PACKAGES+=("$PACKAGE")

  fi

done

# =========================================================
# Installation des paquets manquants
# =========================================================

if [ "${#MISSING_PACKAGES[@]}" -gt 0 ]; then

  echo ""
  echo -e "${YELLOW}=================================================${NC}"
  echo -e "${YELLOW} Paquets manquants${NC}"
  echo -e "${YELLOW}=================================================${NC}"

  for PACKAGE in "${MISSING_PACKAGES[@]}"; do

    echo ""

    if apt-cache show "$PACKAGE" >/dev/null 2>&1; then

      echo -e "${BLUE}$PACKAGE existe dans les dépôts.${NC}"

      read -rp "Installer $PACKAGE ? (o/N) : " INSTALL_PKG

      if [[ "$INSTALL_PKG" =~ ^[oO]$ ]]; then
        sudo apt install -y "$PACKAGE"
      fi

    else

      echo -e "${RED}$PACKAGE n'existe pas dans les dépôts.${NC}"

      echo -e "${YELLOW}Alternatives possibles :${NC}"

      SEARCH_TERM=$(echo "$PACKAGE" | cut -d'-' -f1-2)

      apt-cache search "$SEARCH_TERM" | head -10 || true

    fi

  done

fi

# =========================================================
# Fin
# =========================================================

echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN} Vérification terminée${NC}"
echo -e "${GREEN}=================================================${NC}"


