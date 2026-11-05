# Kate AppImage

[![Build Status](https://github.com/aurelis-packages/aurelis-app-Kate/actions/workflows/appimage.yml/badge.svg)](https://github.com/aurelis-packages/aurelis-app-Kate/actions/workflows/appimage.yml)
[![Latest Release](https://img.shields.io/github/v/release/aurelis-packages/aurelis-app-Kate?label=release)](https://github.com/aurelis-packages/aurelis-app-Kate/releases/latest)
[![Version](https://img.shields.io/badge/version-26.08.2--1-blue)](https://github.com/aurelis-packages/aurelis-app-Kate/releases)
[![Architecture](https://img.shields.io/badge/arch-x86__64%20%7C%20aarch64-lightgrey)](https://github.com/aurelis-packages/aurelis-app-Kate/releases)
[![License](https://img.shields.io/github/license/aurelis-packages/aurelis-app-Kate)](LICENSE)

---

## Description

**Kate** is a powerful, multi-document text editor developed by the KDE community. It features syntax highlighting for over 300 languages, code folding, multiple cursors, split views, integrated terminal, project management, and extensive plugin support. Kate is designed for developers and power users who need a fast, customizable editing environment.

This repository provides **AppImage builds of Kate** that run on any Linux distribution without installation.

---

## Distribution

This is an **Aurelis Linux package**, built using the Aurelis build system. However, the resulting AppImage is **fully portable** and can run as a regular AppImage on **any Linux distribution** (Ubuntu, Fedora, Arch, Debian, openSUSE, etc.) without requiring Aurelis or any special runtime.

### Download

Grab the latest AppImage from the [Releases page](https://github.com/aurelis-packages/aurelis-app-Kate/releases/latest):

- `Kate-<version>-x86_64.AppImage` — for 64-bit Intel/AMD processors
- `Kate-<version>-aarch64.AppImage` — for 64-bit ARM processors (Apple Silicon, Raspberry Pi 4+, etc.)

Make it executable and run:

```bash
chmod +x Kate-*.AppImage
./Kate-*.AppImage
```

---

## Building Locally

Requires an Arch Linux container (provided by the build workflow):

```bash
./get-dependencies.sh
./make-appimage.sh
```

The AppImage will be placed in `./dist/`.

---

## Release Schedule

Builds run automatically every **21 days** via GitHub Actions (see `.github/workflows/appimage.yml`). Manual triggers are also available via the Actions tab.

---

## License

Kate is licensed under **MIT**. See [LICENSE](LICENSE) for details.

---

Thanx to: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)
