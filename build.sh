#!/bin/bash
# ============================================
# Compilador de nano para Tiny Core i686
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
# ============================================
# Este script:
# 1. Instala dependencias
# 2. Descarga nano
# 3. Configura con --enable-utf8 (usa ncursesw)
# 4. Compila
# 5. Instala en directorio temporal
# 6. Estripa binarios
# 7. Crea metadatos
# 8. Empaqueta como .tcz
# ============================================

set -e

# ============================================
# CONFIGURACIÓN
# ============================================
NANO_VERSION="9.2"
BUILD_DIR="$HOME/nano-build"
PACKAGE_DIR="/tmp/nano-package"
OUTPUT_DIR="/tmp"
EXTENSION_NAME="nano-$NANO_VERSION"

# ============================================
# COLORES
# ============================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Compilador de nano para Tiny Core i686${NC}"
echo -e "${GREEN}  Versión: $NANO_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================
# [1/7] INSTALAR DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}[1/7] Instalando dependencias...${NC}"

if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo -e "${RED}Este script requiere dnf o yum (Fedora/RHEL)${NC}"
    exit 1
fi

PACKAGES=(
    "gcc" "gcc-c++" "make" "wget" "tar" "xz"
    "glibc-devel.i686" "libstdc++.i686" "ncurses-devel.i686"
    "squashfs-tools" "groff" "texinfo"
)

echo -e "${YELLOW}Instalando paquetes...${NC}"
$SUDO $PKG_MANAGER install -y "${PACKAGES[@]}" 2>&1 | tail -10

echo 'int main(){return 0;}' > /tmp/test-nano.c
if ! gcc -m32 /tmp/test-nano.c -o /tmp/test-nano 2>/dev/null; then
    echo -e "${RED}Error: GCC no compila para 32 bits${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Dependencias instaladas${NC}"

# ============================================
# [2/7] DESCARGAR NANO
# ============================================
echo -e "\n${YELLOW}[2/7] Descargando nano $NANO_VERSION...${NC}"

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
echo -e "${GREEN}✓ Código fuente extraído${NC}"

# ============================================
# [3/7] CONFIGURAR
# ============================================
echo -e "\n${YELLOW}[3/7] Configurando para i686 con ncursesw...${NC}"

./configure \
    --prefix=/usr/local \
    --host=i686-pc-linux-gnu \
    --disable-extra \
    --enable-nanorc \
    --enable-utf8 \
    --with-ncursesw \
    CFLAGS="-m32 -Os -pipe" \
    LDFLAGS="-m32"

echo -e "${GREEN}✓ Configuración completada${NC}"

# ============================================
# [4/7] COMPILAR
# ============================================
echo -e "\n${YELLOW}[4/7] Compilando nano...${NC}"
make -j$(nproc)
echo -e "${GREEN}✓ Compilación completada${NC}"

# ============================================
# [5/7] INSTALAR Y ESTRIBAR
# ============================================
echo -e "\n${YELLOW}[5/7] Instalando en $PACKAGE_DIR...${NC}"

rm -rf "$PACKAGE_DIR"
make install-strip DESTDIR="$PACKAGE_DIR"

# Crear nanorc de ejemplo
mkdir -p "$PACKAGE_DIR/usr/local/share/nano"
cp doc/sample.nanorc "$PACKAGE_DIR/usr/local/share/nano/nanorc" 2>/dev/null || true

echo -e "${GREEN}✓ Instalación completada${NC}"

# ============================================
# [6/7] CREAR METADATOS
# ============================================
echo -e "\n${YELLOW}[6/7] Creando metadatos...${NC}"

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
Change-log:     Compilado manualmente
Current:        $(date +%Y-%m-%d)
EOF

cat > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.dep" << EOF
ncursesw.tcz
file.tcz
EOF

cd "$PACKAGE_DIR"
find usr -not -type d > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.list"

echo -e "${GREEN}✓ Metadatos creados${NC}"

# ============================================
# [7/7] EMPAQUETAR
# ============================================
echo -e "\n${YELLOW}[7/7] Empaquetando como .tcz...${NC}"

cd /tmp
mksquashfs nano-package "$EXTENSION_NAME.tcz"

md5sum "$EXTENSION_NAME.tcz" > "$EXTENSION_NAME.tcz.md5.txt"
cp "$PACKAGE_DIR/usr/local/share/nano.tcz.info" "$OUTPUT_DIR/$EXTENSION_NAME.tcz.info"

echo -e "${GREEN}✓ Paquete creado${NC}"

# ============================================
# RESUMEN FINAL
# ============================================
echo -e "\n${GREEN}¡COMPILACIÓN COMPLETADA!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
ls -lh "$OUTPUT_DIR/$EXTENSION_NAME"* 2>/dev/null || true
echo ""
echo -e "${YELLOW}Para instalar en Tiny Core:${NC}"
echo "  1. Copia $EXTENSION_NAME.tcz a /etc/sysconfig/tcedir/optional/"
echo "  2. Ejecuta: tce-load -i $EXTENSION_NAME"
echo "  3. Verifica: nano --version"
echo ""
echo -e "${GREEN}¡Listo!${NC}"
