#!/bin/bash
# ============================================
# Compilador AUTOMÁTICO de Nano para Tiny Core i686
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
# ============================================

set -e

# ============================================
# CONFIGURACIÓN
# ============================================
BUILD_DIR="$HOME/nano-build"
PACKAGE_DIR="/tmp/nano-package"
OUTPUT_DIR="/tmp"
VERSION_FILE="$HOME/nano-version.txt"

# ============================================
# COLORES
# ============================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Compilador AUTOMÁTICO de Nano i686${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================
# [1/8] BUSCAR LA ÚLTIMA VERSIÓN
# ============================================
echo -e "\n${YELLOW}[1/8] Buscando la última versión de Nano...${NC}"

LATEST_DIR=$(wget -qO- https://www.nano-editor.org/dist/ | grep -oP 'v\K[0-9]+' | sort -nr | head -n 1)
LATEST_VERSION=$(wget -qO- "https://www.nano-editor.org/dist/v${LATEST_DIR}/" | grep -oP 'nano-\K[0-9]+\.[0-9]+(?=\.tar\.xz)' | sort -V | tail -n 1)

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}Error: No se pudo obtener la versión. Usando 9.2 por defecto.${NC}"
    NANO_VERSION="9.2"
else
    NANO_VERSION="$LATEST_VERSION"
fi

echo -e "${GREEN}✓ Última versión detectada: $NANO_VERSION${NC}"
echo "$NANO_VERSION" > "$VERSION_FILE"
EXTENSION_NAME="nano-$NANO_VERSION"

# ============================================
# [2/8] INSTALAR DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}[2/8] Instalando dependencias...${NC}"

if [ "$EUID" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
if command -v dnf &> /dev/null; then PKG_MANAGER="dnf"; else PKG_MANAGER="yum"; fi

PACKAGES=(
    "gcc" "gcc-c++" "make" "wget" "tar" "xz"
    "glibc-devel.i686" "libstdc++.i686" "ncurses-devel.i686"
    "squashfs-tools" "groff" "texinfo"
)
$SUDO $PKG_MANAGER install -y "${PACKAGES[@]}" 2>&1 | tail -5

# ============================================
# [3/8] DESCARGAR CÓDIGO FUENTE
# ============================================
echo -e "\n${YELLOW}[3/8] Descargando Nano $NANO_VERSION...${NC}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -f "nano-$NANO_VERSION.tar.xz" ]; then
    wget "https://www.nano-editor.org/dist/v${LATEST_DIR}/nano-$NANO_VERSION.tar.xz"
fi

if [ -d "nano-$NANO_VERSION" ]; then
    rm -rf "nano-$NANO_VERSION"
fi
tar -xf "nano-$NANO_VERSION.tar.xz"
cd "nano-$NANO_VERSION"

# ============================================
# [4/8] CONFIGURAR
# ============================================
echo -e "\n${YELLOW}[4/8] Configurando para i686 con ncursesw...${NC}"

./configure \
    --prefix=/usr/local \
    --host=i686-pc-linux-gnu \
    --disable-extra \
    --enable-nanorc \
    --enable-utf8 \
    --with-ncursesw \
    CFLAGS="-m32 -Os -pipe" \
    LDFLAGS="-m32"

# ============================================
# [5/8] COMPILAR
# ============================================
echo -e "\n${YELLOW}[5/8] Compilando Nano...${NC}"
make -j$(nproc)

# ============================================
# [6/8] INSTALAR, ESTRIBAR Y CREAR ENLACES
# ============================================
echo -e "\n${YELLOW}[6/8] Instalando, estripando y creando enlaces...${NC}"
rm -rf "$PACKAGE_DIR"
make install-strip DESTDIR="$PACKAGE_DIR"

mkdir -p "$PACKAGE_DIR/usr/local/share/nano"
cp doc/sample.nanorc "$PACKAGE_DIR/usr/local/share/nano/nanorc" 2>/dev/null || true

if [ -f "$PACKAGE_DIR/usr/local/bin/nano" ]; then
    strip "$PACKAGE_DIR/usr/local/bin/nano"
fi
find "$PACKAGE_DIR" -type f -exec file {} \; 2>/dev/null | grep 'ELF' | awk -F: '{print $1}' | xargs strip 2>/dev/null || true

# --- SOLUCIÓN DEFINITIVA PARA TINY CORE ---
# Crear el enlace en /usr/lib (donde el cargador dinámico busca por defecto)
mkdir -p "$PACKAGE_DIR/usr/lib"
cd "$PACKAGE_DIR/usr/lib"
ln -sf /usr/local/lib/libncursesw.so.6 libtinfo.so.6
ln -sf /usr/local/lib/libncursesw.so.6 libncurses.so.6
cd - > /dev/null
# ------------------------------------------

# ============================================
# [7/8] CREAR METADATOS
# ============================================
echo -e "\n${YELLOW}[7/8] Creando metadatos...${NC}"
PACKAGE_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)

mkdir -p "$PACKAGE_DIR/usr/local/share"
cat > "$PACKAGE_DIR/usr/local/share/nano.tcz.info" << EOF
Title:          nano.tcz
Description:    GNU nano text editor (v$NANO_VERSION)
Version:        $NANO_VERSION
Author:         GNU nano Team
Original-site:  https://www.nano-editor.org
Copying-policy: GPLv3
Size:           $PACKAGE_SIZE
Extension_by:   Jose Andres Mamani Mollericona
Comments:       Compilado para i686 (github.com/JOSSEL01)
Current:        $(date +%Y-%m-%d)
EOF

cat > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.dep" << EOF
ncursesw.tcz
file.tcz
EOF

cd "$PACKAGE_DIR"
find usr -not -type d > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.list"

# ============================================
# [8/8] EMPAQUETAR
# ============================================
echo -e "\n${YELLOW}[8/8] Empaquetando .tcz...${NC}"
cd /tmp
mksquashfs nano-package "$EXTENSION_NAME.tcz"
md5sum "$EXTENSION_NAME.tcz" > "$EXTENSION_NAME.tcz.md5.txt"
cp "$PACKAGE_DIR/usr/local/share/nano.tcz.info" "$OUTPUT_DIR/$EXTENSION_NAME.tcz.info"

echo -e "\n${GREEN}¡COMPILACIÓN COMPLETADA!${NC}"
ls -lh "$OUTPUT_DIR/$EXTENSION_NAME"* 2>/dev/null || true
