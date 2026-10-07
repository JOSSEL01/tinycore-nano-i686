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
- ✅ Compatible con **ncursesw** (soporte UTF-8)
- ✅ Binario **estripado** para reducir tamaño
- ✅ Tamaño del paquete: **~1 MB**

---

## 📦 Requisitos

- **Tiny Core Linux 17.0** (o compatible)
- **Arquitectura i686** (32 bits)
- Al menos **5 MB de espacio libre** en disco
- Dependencias: `ncursesw.tcz`, `file.tcz`

---

## 🚀 Instalación rápida

Desde la terminal de tu Tiny Core:

```bash
wget https://github.com/JOSSEL01/tinycore-nano-i686/raw/main/packages/nano-9.2.tcz
sudo mv nano-9.2.tcz /mnt/sda(_)/tce/optional/
tce-load -i nano-9.2
nano --version
```

Deberías ver: `GNU nano, version 9.2`

---

## 🔧 Instalación manual

1. Descarga `nano-9.2.tcz` desde la carpeta `packages/`.
2. Cópialo a `/mnt/sda(_)/tce/optional/` en tu Tiny Core.
3. Ejecuta:
   ```bash
   tce-load -i nano-9.2
   ```
4. Colocar en Onboot:
   nano /etc/sysconfig/tcedir/onboot.lst

   Ir hasta la parte final del archivo y poner nano-9.2.tcz y con las teclas ctrl + o luego enter luego ctrl + x y ya estaria
   
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
| **Flags** | `--disable-extra --enable-nanorc --enable-utf8` |

---

## 🐛 Solución de problemas

### Error: `nano: error while loading shared libraries: libncurses.so.6`

**Causa:** El sistema solo tiene `libncursesw.so.6`, no `libncurses.so.6`.

**Solución:**
```bash
sudo ln -sf /usr/local/lib/libncursesw.so.6 /usr/local/lib/libncurses.so.6
```

### Error: `nano: command not found`

**Solución:**
```bash
tce-load -i nano-9.2
which nano
```

---

## 🔨 Recompilar desde cero

Usa el script `build.sh` incluido en este repositorio:

```bash
chmod +x build.sh
./build.sh
```

Edita la variable `NANO_VERSION` en `build.sh` para cambiar de versión.

---

## 📄 Licencia

GNU nano es software libre bajo la [licencia GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).

---

## 📞 Contacto

- **Autor:** Jose Andres Mamani Mollericona
- **GitHub:** [@JOSSEL01](https://github.com/JOSSEL01)
- **Repositorio:** [tinycore-nano-i686](https://github.com/JOSSEL01/tinycore-nano-i686)
