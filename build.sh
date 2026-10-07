#!/bin/bash
# ============================================
# Compilador de nano para Tiny Core i686
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
# Basado en el script oficial de Tiny Core
# ============================================

set -e

# Configuración
NANO_VERSION="9.2"  # Última versión estable
BUILD_DIR="$HOME/nano-build"
PACKAGE_DIR="/tmp/nano-package"
OUTPUT_DIR="/tmp"
EXTENSION_NAME="nano-$NANO_VERSION"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Compilador de nano para Tiny Core i686${NC}"
echo -e "${GREEN}  Versión: $NANO_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# Verificar root
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# [1/6] Instalar dependencias
echo -e "\n${YELLOW}[1/6] Instalando dependencias...${NC}"

if command -v dnf &> /dev/null; then
    $SUDO dnf install -y gcc gcc-c++ make wget tar xz \
        glibc-devel.i686 libstdc++.i686 ncurses-devel.i686 \
        squashfs-tools groff texinfo
else
    echo -e "${RED}Este script requiere dnf (Fedora/RHEL)${NC}"
    exit 1
fi

# [2/6] Descargar nano
echo -e "\n${YELLOW}[2/6] Descargando nano $NANO_VERSION...${NC}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -f "nano-$NANO_VERSION.tar.xz" ]; then
    wget "https://www.nano-editor.org/dist/v9/nano-$NANO_VERSION.tar.xz"
fi

if [ -d "nano-$NANO_VERSION" ]; then
    rm -rf "nano-$NANO_VERSION"
fi
tar -xf "nano-$NANO_VERSION.tar.xz"
cd "nano-$NANO_VERSION"

# [3/6] Configurar
echo -e "\n${YELLOW}[3/6] Configurando para i686...${NC}"

# Crear symlink para ncursesw (como en el script oficial)
ln -sf /usr/include/ncursesw/ncurses.h /usr/include/ncurses.h 2>/dev/null || true
ln -sf /usr/lib/pkgconfig/ncursesw.pc /usr/lib/pkgconfig/ncurses.pc 2>/dev/null || true

./configure \
    --prefix=/usr/local \
    --host=i686-pc-linux-gnu \
    --disable-extra \
    --enable-nanorc \
    --disable-utf8 \
    CFLAGS="-m32 -Os -pipe" \
    LDFLAGS="-m32"

# [4/6] Compilar
echo -e "\n${YELLOW}[4/6] Compilando...${NC}"

make -j$(nproc)

# [5/6] Instalar en directorio temporal
echo -e "\n${YELLOW}[5/6] Instalando en $PACKAGE_DIR...${NC}"

rm -rf "$PACKAGE_DIR"
make install-strip DESTDIR="$PACKAGE_DIR"

# Crear nanorc de ejemplo (como en el script oficial)
mkdir -p "$PACKAGE_DIR/usr/local/share/nano"
cp doc/sample.nanorc "$PACKAGE_DIR/usr/local/share/nano/nanorc"
sed -i 's|# include "/usr| include "/usr|' "$PACKAGE_DIR/usr/local/share/nano/nanorc" 2>/dev/null || true

# [6/6] Crear metadatos y empaquetar
echo -e "\n${YELLOW}[6/6] Creando metadatos y empaquetando...${NC}"

PACKAGE_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)

# Crear .info
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
Change-log:     Compilado manualmente
Current:        $(date +%Y-%m-%d)
EOF

# Crear .dep (dependencias de nano)
cat > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.dep" << EOF
ncursesw.tcz
file.tcz
EOF

# Crear .list
cd "$PACKAGE_DIR"
find usr -not -type d > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.list"

# Empaquetar
cd /tmp
mksquashfs nano-package "$EXTENSION_NAME.tcz"

# Crear .md5.txt
md5sum "$EXTENSION_NAME.tcz" > "$EXTENSION_NAME.tcz.md5.txt"

# Copiar .info al directorio de salida
cp "$PACKAGE_DIR/usr/local/share/nano.tcz.info" "$OUTPUT_DIR/$EXTENSION_NAME.tcz.info"
# Resumen
echo -e "\n${GREEN}¡COMPILACIÓN COMPLETADA!${NC}"
echo -e "${GREEN}========================================${NC}"
ls -lh "$OUTPUT_DIR/$EXTENSION_NAME"* 2>/dev/null || true
echo ""
echo -e "${YELLOW}Para instalar en Tiny Core:${NC}"
echo "  1. Copia $EXTENSION_NAME.tcz a /etc/sysconfig/tcedir/optional/"
echo "  2. Ejecuta: tce-load -i $EXTENSION_NAME"
echo "  3. Verifica: nano --version"
echo ""
echo -e "${GREEN}¡Listo!${NC}"
