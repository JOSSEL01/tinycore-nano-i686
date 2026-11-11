# GNU nano 9.3 para Tiny Core Linux i686

![nano](https://img.shields.io/badge/nano-v9.3-blue)
![Platform](https://img.shields.io/badge/Platform-i686-green)
![Tiny Core](https://img.shields.io/badge/Tiny%20Core-17.0-orange)
![License](https://img.shields.io/badge/License-GPLv3-yellow)

Extensión `.tcz` de **GNU nano 9.3** compilada para **Tiny Core Linux 17.0 (i686, 32 bits)**.

---

## 📋 Tabla de contenidos

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación rápida](#-instalación-rápida)
- [Instalación manual](#-instalación-manual)
- [Actualización](#-actualización)
- [Verificación](#-verificación)
- [Detalles de compilación](#-detalles-de-compilación)
- [Solución de problemas](#-solución-de-problemas)
- [Recompilar desde cero](#-recompilar-desde-cero)
- [Licencia](#-licencia)

---

## ✨ Características

- ✅ GNU nano **v9.3** (última versión estable)
- ✅ Compilado para **i686 (32 bits)**
- ✅ Compatible con **ncursesw** (soporte UTF-8)
- ✅ Incluye enlaces simbólicos para `libtinfo` (soluciona error de librerías)
- ✅ Binario **estripado** para reducir tamaño

---

## 📦 Requisitos

- **Tiny Core Linux 17.0** (o compatible)
- **Arquitectura i686** (32 bits)
- Dependencias: `ncursesw.tcz`, `file.tcz`

---

## 🚀 Instalación rápida

Desde la terminal de tu Tiny Core:

```bash
wget https://github.com/JOSSEL01/tinycore-nano-i686/raw/main/packages/nano-9.3.tcz
sudo mv nano-9.3.tcz /mnt/sda(_)/tce/optional/
tce-load -i nano-9.3
nano --version
```

Deberías ver: `GNU nano, version 9.3`

---

## 🔧 Instalación manual

1. Descarga `nano-9.3.tcz` desde la carpeta `packages/`.
2. Cópialo a `/mnt/sda(_)/tce/optional/` en tu Tiny Core.
3. Ejecuta:
   ```bash
   tce-load -i nano-9.3
   ```
4. Colocar en Onboot: `nano /etc/sysconfig/tcedir/onboot.lst`
5. Ir hasta la parte final del archivo y poner `nano-9.3.tcz` y con las teclas Ctrl + O luego Enter luego Ctrl + X y ya estaría.

---

## 🔄 Actualización

Si ya tienes una versión anterior de Nano instalada, sigue estos pasos para actualizar sin conflictos:

1. **Desinstala la versión anterior:**
   ```bash
   tce-remove nano-9.2
   ```
2. **Instala la nueva versión:**
   ```bash
   wget https://github.com/JOSSEL01/tinycore-nano-i686/raw/main/packages/nano-9.3.tcz
   sudo mv nano-9.3.tcz /mnt/sda(_)/tce/optional/
   tce-load -i nano-9.3
   ```
3. **Actualiza el archivo `onboot.lst` (si lo usas):**
   ```bash
   nano /etc/sysconfig/tcedir/onboot.lst
   ```
   Cambia el nombre de `nano-9.2.tcz` por `nano-9.3.tcz`.

---

## ✅ Verificación

```bash
nano --version
# Salida esperada: GNU nano, version 9.3

which nano
# Salida esperada: /usr/local/bin/nano
```

---

## 🛠️ Detalles de compilación

| Parámetro | Valor |
|---|---|
| **Versión de nano** | 9.3 |
| **Sistema anfitrión** | Fedora 43 x86_64 |
| **Arquitectura objetivo** | i686 (32 bits) |
| **Flags** | `--disable-extra --enable-nanorc --enable-utf8 --with-ncursesw` |

---

## 🐛 Solución de problemas

### Error: `nano: error while loading shared libraries: libtinfo.so.6`

**Causa:** El sistema busca `libtinfo` pero el paquete incluye los enlaces para que funcione con `libncursesw`.

**Solución:** Este paquete `.tcz` ya incluye los enlaces simbólicos necesarios (`libtinfo.so.6` -> `libncursesw.so.6`). Si el error persiste, asegúrate de tener instalado `ncursesw.tcz`:
```bash
tce-load -wi ncursesw
```

---

## 🔨 Recompilar desde cero

Usa el script `build.sh` incluido en este repositorio:

```bash
chmod +x build.sh
./build.sh
```

El script buscará y compilará automáticamente la última versión de Nano e incluirá los enlaces simbólicos necesarios.

---

## 📄 Licencia

GNU nano es software libre bajo la [licencia GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).

---

## 📞 Contacto

- **Autor:** Jose Andres Mamani Mollericona
- **GitHub:** [@JOSSEL01](https://github.com/JOSSEL01)
- **Repositorio:** [tinycore-nano-i686](https://github.com/JOSSEL01/tinycore-nano-i686)
