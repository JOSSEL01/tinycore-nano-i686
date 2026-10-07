# GNU nano 9.2 para Tiny Core Linux i686

![nano](https://img.shields.io/badge/nano-v9.2-blue)
![Platform](https://img.shields.io/badge/Platform-i686-green)
![Tiny Core](https://img.shields.io/badge/Tiny%20Core-17.0-orange)
![License](https://img.shields.io/badge/License-GPLv3-yellow)

Extensión `.tcz` de **GNU nano 9.2** compilada para **Tiny Core Linux 17.0 (i686, 32 bits)**.

---

## 📋 Tabla de contenidos

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación rápida](#-instalación-rápida)
- [Instalación manual](#-instalación-manual)
- [Verificación](#-verificación)
- [Detalles de compilación](#-detalles-de-compilación)
- [Solución de problemas](#-solución-de-problemas)
- [Recompilar desde cero](#-recompilar-desde-cero)
- [Licencia](#-licencia)

---

## ✨ Características

- ✅ GNU nano **v9.2** (última versión estable)
- ✅ Compilado para **i686 (32 bits)**
- ✅ Binario **estripado** para reducir tamaño
- ✅ Compatible con **ncursesw**
- ✅ Tamaño del paquete: **~150 KB**

---

## 📦 Requisitos

- **Tiny Core Linux 17.0** (o compatible)
- **Arquitectura i686** (32 bits)
- Al menos **1 MB de espacio libre** en disco
- Dependencias: `ncursesw.tcz`, `file.tcz`

---

## 🚀 Instalación rápida

Desde la terminal de tu Tiny Core:

```bash
wget https://github.com/JOSSEL01/tinycore-nano-i686/raw/main/packages/nano-9.2.tcz
sudo mv nano-9.2.tcz /etc/sysconfig/tcedir/optional/
tce-load -i nano-9.2
nano --version
```

Deberías ver: `GNU nano, version 9.2`

---

## 🔧 Instalación manual

1. Descarga `nano-9.2.tcz` desde la carpeta [`packages/`](packages/).
2. Cópialo a `/mnt/sda(_)/tce/optional/` en tu Tiny Core.
3. Ejecuta:
   ```bash
   tce-load -i nano-9.2
   ```

4. Colocar en Onboot
   ```nano /etc/sysconfig/tcedir/onboot.lst

   Ir hasta la parte final del archivo y poner node-v20.19.2.tcz y con las teclas ctrl + o luego enter luego ctrl + x y ya estaria
   ```
   
5. Verifica:
   ```bash
   nano --version
   ```

---

## ✅ Verificación

```bash
nano --version
# Salida esperada: GNU nano, version 9.2

which nano
# Salida esperada: /usr/local/bin/nano
```

---

## 🛠️ Detalles de compilación

| Parámetro | Valor |
|---|---|
| **Versión de nano** | 9.2 |
| **Sistema anfitrión** | Fedora 43 x86_64 |
| **Arquitectura objetivo** | i686 (32 bits) |
| **GCC** | 15.2.0 |
| **Flags** | `--disable-extra --enable-nanorc --disable-utf8` |

---

## 🐛 Solución de problemas

### Error: `nano: error while loading shared libraries: libncursesw.so.6`

**Solución:**
```bash
tce-load -wi ncursesw
```

### Error: `nano: command not found`

**Solución:**
```bash
tce-load -i nano-9.2
which nano
```

### nano no responde a las teclas

**Solución:**
```bash
export TERM=linux
nano archivo.txt
```

---

## 🔨 Recompilar desde cero

Usa el script `build.sh` incluido en este repositorio:

```bash
chmod +x build.sh
./build.sh
```

Edita la variable `NANO_VERSION` en `build.sh` para cambiar de versión.

**Dependencias para compilar en Fedora:**
```bash
sudo dnf install -y gcc gcc-c++ make wget tar xz \
  glibc-devel.i686 libstdc++.i686 ncurses-devel.i686 \
  squashfs-tools groff texinfo
```

---

## 📄 Licencia

GNU nano es software libre bajo la [licencia GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).

Este repositorio solo contiene los binarios compilados y los scripts de compilación.

---

## 📞 Contacto

- **Autor:** Jose Andres Mamani Mollericona
- **GitHub:** [@JOSSEL01](https://github.com/JOSSEL01)
- **Repositorio:** [tinycore-nano-i686](https://github.com/JOSSEL01/tinycore-nano-i686)

Si encuentras algún problema o tienes sugerencias, abre un [issue](https://github.com/JOSSEL01/tinycore-nano-i686/issues) en el repositorio.
