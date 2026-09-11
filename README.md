<p align="center">
  <img src=".github/assets/addon-icon.png" width="128" height="128" alt="Raidex Keys icon">
</p>

<h1 align="center">Raidex Keys</h1>

<p align="center">
  <em>Deine Mythic+-Woche im Blick – auch wenn WoW zu ist.</em><br>
  <em>Your Mythic+ week at a glance – even with WoW closed.</em>
</p>

<p align="center">
  <a href="https://github.com/incudex/raidex-keys/releases"><b>Download</b></a> ·
  <a href="https://github.com/incudex/raidex-keys/issues/new/choose">Report a bug</a> ·
  <a href="https://raidex.app/keys/">raidex.app/keys</a>
</p>

<p align="center">
  <a href="https://github.com/incudex/raidex-keys/releases"><img alt="newest release" src="https://img.shields.io/github/v/release/incudex/raidex-keys?include_prereleases&label=download&color=7C5CFF"></a>
  <a href="#download"><img alt="Windows 10 and 11" src="https://img.shields.io/badge/Windows-10%20%C2%B7%2011-2F6FBF?logo=windows&logoColor=white"></a>
  <a href="#download"><img alt="Linux packages" src="https://img.shields.io/badge/Linux-.deb%20%C2%B7%20.tar.gz-3E4C59?logo=linux&logoColor=white"></a>
  <a href="addon/RaidexKeys"><img alt="World of Warcraft 12.1.0" src="https://img.shields.io/badge/WoW-retail%2012.1.0-B8873B"></a>
  <a href="LICENSE"><img alt="addon licence" src="https://img.shields.io/badge/addon-GPL--3.0--or--later-2C7BB6"></a>
  <a href="#licence"><img alt="app licence" src="https://img.shields.io/badge/app-freeware-5A6472"></a>
  <a href="https://raidex.app/keys/"><img alt="languages" src="https://img.shields.io/badge/languages-DE%20%C2%B7%20EN-3B7DD8"></a>
  <a href="https://raidex.app"><img alt="made with love in Europe" src="https://img.shields.io/badge/made%20with%20%3C3%20in-Europe-003399"></a>
</p>

Mythic+ keystones, ratings, the Great Vault, your Mythic Dungeon Tools routes
and your guild's keys: all of it on the desktop (Windows and Linux), outside
the game. A small WoW addon records what the game knows, and the app reads it.
Part of the [Raidex](https://raidex.app) family.

<p align="center">
  <img src=".github/assets/overview.png" width="900" alt="The app's overview: rating, best run per dungeon, the next key and the goal">
</p>

More pictures on [raidex.app/keys](https://raidex.app/keys/#einblicke).

This repository hosts the **releases**, the **issue tracker** and the
**addon** ([`addon/RaidexKeys`](addon/RaidexKeys)), in the form WoW loads it.
The desktop app is closed source, and its builds are free to use.

## Download

Get the [newest release](https://github.com/incudex/raidex-keys/releases).
It contains:

| File | What it is |
|---|---|
| `raidex-keys-<version>-win-x64-setup.exe` | the app for Windows 10 and 11 (64-bit), as installer. It installs for your user, no admin rights needed, and puts the WoW addon in too if you like. Uninstall it from Windows' app list. |
| `raidex-keys-<version>-win-x64.zip` | the same app without installing: unzip it anywhere and start `RaidexKeys.exe`. |
| `raidex-keys_<version>_amd64.deb` | the app for Debian 12+, Ubuntu 22.04+, Linux Mint 21+ and their relatives (64-bit). Install it with `sudo apt install ./raidex-keys_<version>_amd64.deb`, or open it with your package installer. `sudo apt remove raidex-keys` removes it again. |
| `raidex-keys-<version>-linux-x64.tar.gz` | the app for every other Linux (64-bit). Unpack it and run `./install.sh`, which installs to `~/.local`. `./install.sh --uninstall` removes it again. |
| `raidex-keys-addon-<version>.zip` | the WoW addon - the Windows installer brings it along. Unpack it into `World of Warcraft/_retail_/Interface/AddOns`. |
| `SHA256SUMS` | checksums of the files above |
| Source code (zip, tar.gz) | the addon as of this release, added by GitHub |

Windows may warn that it "protected your PC" when you start the installer or
the app for the first time: the files are not signed yet. Click "More info",
then "Run anyway".

Switching from `install.sh` to the `.deb`? Run `./install.sh --uninstall`
first - otherwise the copy in `~/.local` keeps starting instead of the
package. Your settings stay either way.

The app needs the addon. WoW saves the addon's data when you log out or type
`/reload`, and the app picks it up from there. When the app starts for the
first time, it asks for your AddOns folder - unless the Windows installer put
the addon in; then you confirmed the folder there.

## Report a bug or suggest something

[Open an issue](https://github.com/incudex/raidex-keys/issues/new/choose) and
pick the app or the addon. If you're not sure which one is at fault, pick the
app. You can write in German or English.

## Licence

Copyright © 2026 incūdex, Lars Gossard · <raidex@incudex.de>

- **The addon** is free software: you can redistribute it and/or modify it
  under the terms of the [GNU General Public License](LICENSE) as published
  by the Free Software Foundation, either version 3 of the License, or (at
  your option) any later version.
- **The desktop app** is freeware: free to use and to pass on unchanged, but
  not to modify or sell. The full terms are in `LICENSE.txt` in the
  download.

Both come without any warranty.

World of Warcraft is a trademark of Blizzard Entertainment, Inc. Raidex Keys is
not affiliated with Blizzard.
