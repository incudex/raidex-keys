<p align="center">
  <img src="https://raw.githubusercontent.com/incudex/raidex-keys/main/.github/assets/addon-icon.png" width="128" height="128" alt="Raidex Keys icon">
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
  <a href="https://github.com/incudex/raidex-keys#download"><img alt="Windows 10 and 11" src="https://img.shields.io/badge/Windows-10%20%C2%B7%2011-2F6FBF?logo=windows&logoColor=white"></a>
  <a href="https://github.com/incudex/raidex-keys#download"><img alt="Linux packages" src="https://img.shields.io/badge/Linux-.deb%20%C2%B7%20.tar.gz-3E4C59?logo=linux&logoColor=white"></a>
  <a href="https://github.com/incudex/raidex-keys/tree/main/addon/RaidexKeys"><img alt="World of Warcraft 12.1.0" src="https://img.shields.io/badge/WoW-retail%2012.1.0-B8873B"></a>
  <a href="https://github.com/incudex/raidex-keys/blob/main/LICENSE"><img alt="addon licence" src="https://img.shields.io/badge/addon-GPL--3.0--or--later-2C7BB6"></a>
  <a href="https://github.com/incudex/raidex-keys#licence"><img alt="app licence" src="https://img.shields.io/badge/app-freeware-5A6472"></a>
  <a href="https://raidex.app/keys/"><img alt="languages" src="https://img.shields.io/badge/languages-DE%20%C2%B7%20EN-3B7DD8"></a>
  <a href="https://raidex.app"><img alt="made with love in Europe" src="https://img.shields.io/badge/made%20with%20%3C3%20in-Europe-003399"></a>
</p>

Mythic+ keystones, ratings, the Great Vault, your Mythic Dungeon Tools routes
and your guild's keys - in game and on the desktop (Windows and Linux). Two
parts, each on its own and better together: a **WoW addon** with a window of
every key that matters to you, your guild's key board and a Mythic+ timer, and
a **desktop app** that reads what the addon records and shows your week
outside the game. Part of the [Raidex](https://raidex.app) family.

<p align="center">
  <img src="https://raw.githubusercontent.com/incudex/raidex-keys/main/.github/assets/overview.png" width="900" alt="The desktop app's overview: rating, best run per dungeon, the next key and the goal">
</p>

More pictures on [raidex.app/keys](https://raidex.app/keys/#einblicke).

This repository hosts the **releases**, the **issue tracker** and the
**addon** ([`addon/RaidexKeys`](https://github.com/incudex/raidex-keys/tree/main/addon/RaidexKeys)), in the form WoW loads it.
The desktop app is closed source, and its builds are free to use.

## The addon

<p align="center">
  <img src="https://raw.githubusercontent.com/incudex/raidex-keys/main/.github/assets/addon-window.png" width="440" alt="The addon's window: your guild's keys this week, grouped by dungeon">
  <img src="https://raw.githubusercontent.com/incudex/raidex-keys/main/.github/assets/addon-timer.png" width="440" alt="The addon's Mythic+ timer during a key">
</p>

The addon needs no app. In game it brings:

- **A window** with five tabs. *Guild*: your guild's keys this week, grouped
  by dungeon. *Alts*: every character's key, this week's runs, Great Vault
  and rating - an alt is in it without logging it in. *Group*: the keys of
  the group you are in. *Rating goals*: the fewest runs that lift you to 2500,
  3000 and 3500 rating, each at the lowest level that does it, and who in your
  alts, group or guild holds a key for it. *Board*: your guild's key board.
  Left open, the window is back after a `/reload` or a loading screen.
- **The key board**: pin your key for a day and a time, with a note such as
  "a few more keys afterwards". Guild members sign up as tank, healer or
  damage, up to ten, counted against a group of five - so you can still talk
  it over with those who come too late; a click on a name whispers them. The
  board travels through your guild's addon channel and reaches members who
  were offline when the key was pinned.
- **A Mythic+ timer** while a key runs: the time left with the +2 and +3
  limits, every boss with the time it fell and your best time, the enemy
  forces to two decimals, the deaths and what they cost, and where your rating
  would land if the run ended now. After every boss your own chat says when it
  fell; at the end the key's holder tells the group how it went.
- **A minimap button** whose tooltip shows your key, how many keys of your
  group are known and how many keys your guild has this week. A click opens
  the window, shift-click the options, ctrl-click shows or hides the timer,
  right-click links your key in the chat.
- **Options** under *Options → AddOns → Raidex Keys*: sharing your key with
  the guild, the window's font and size, and what the timer shows, says and
  looks like. The addon speaks your client's language, German or English.

It also records every character's keystone, rating, best runs and Great Vault
for the desktop app.

## The desktop app

- **Every character's keystone**, rating and best runs.
- **Rating calculator**: the runs to your rating goal, and what every key
  would add.
- **Great Vault** progress for every character, including last week's reward
  still waiting.
- **Your Mythic Dungeon Tools routes**, with the enemy forces per pull, drawn
  on the dungeon's map.
- **Your guild's keys** this week.
- **Group planner**: pick who plays tonight, and see which of their keys
  gives the group the most rating - with tank, healer and three damage dealers
  and a fitting item level, if you like.
- With a **Raidex account**, connected by a short code, your guild shares its
  keys and routes, and Raidex's **raid calendar** - raids, sign-ups and the
  guides of every instance - has a page of its own.

Everything about your own characters works without an account: it comes from
the addon.

## Download

Get the [newest release](https://github.com/incudex/raidex-keys/releases).
It contains:

| File | What it is |
|---|---|
| `raidex-keys-<version>-win-x64-setup.exe` | the app for Windows 10 and 11 (64-bit), as installer. It installs for your user, no admin rights needed, and puts the WoW addon in too if you like. Uninstall it from Windows' app list. |
| `raidex-keys-<version>-win-x64.zip` | the same app without installing: unzip it anywhere and start `RaidexKeys.exe`. |
| `raidex-keys_<version>_amd64.deb` | the app for Debian 12+, Ubuntu 22.04+, Linux Mint 21+ and their relatives (64-bit). Install it with `sudo apt install ./raidex-keys_<version>_amd64.deb`, or open it with your package installer. `sudo apt remove raidex-keys` removes it again. |
| `raidex-keys-<version>-linux-x64.tar.gz` | the app for every other Linux (64-bit). Unpack it and run `./install.sh`, which installs to `~/.local`. `./install.sh --uninstall` removes it again. |
| `raidex-keys-addon-<version>.zip` | the WoW addon, which runs on its own - the Windows installer brings it along. Unpack it into `World of Warcraft/_retail_/Interface/AddOns`. |
| `SHA256SUMS` | checksums of the files above |
| Source code (zip, tar.gz) | the addon as of this release, added by GitHub |

Windows may warn that it "protected your PC" when you start the installer or
the app for the first time: the files are not signed yet. Click "More info",
then "Run anyway".

Switching from `install.sh` to the `.deb`? Run `./install.sh --uninstall`
first - otherwise the copy in `~/.local` keeps starting instead of the
package. Your settings stay either way.

The app needs the addon. WoW saves the addon's data when you log out or type
`/reload`, and the app picks it up from there - so the app always shows the
state of your last logout, and says how old every value is. When the app
starts for the first time, it asks for your AddOns folder - unless the
Windows installer put the addon in; then you confirmed the folder there.

## Your data

The addon sends nothing to a server. It writes a file to your own disk, which
the desktop app - if you use it - reads on the same computer. The key board
goes to your guild members' addons only, through the game's addon channel.
Only when you connect the app to a Raidex account - your choice, and needed
for none of the above - do your keys reach your guild through Raidex.

## Getting along with other addons

LibKeystone is **not shipped**. If another addon such as BigWigs has already
loaded it, Raidex Keys uses that one, so nobody answers twice; otherwise the
addon speaks the protocol itself. Astral Keys and its relatives can stay where
they are.

## Report a bug or suggest something

[Open an issue](https://github.com/incudex/raidex-keys/issues/new/choose) and
pick the app or the addon. If you're not sure which one is at fault, pick the
app. You can write in German or English.

## Licence

Copyright © 2026 incūdex, Lars Gossard · <raidex@incudex.de>

- **The addon** is free software: you can redistribute it and/or modify it
  under the terms of the [GNU General Public License](https://github.com/incudex/raidex-keys/blob/main/LICENSE) as published
  by the Free Software Foundation, either version 3 of the License, or (at
  your option) any later version.
- **The desktop app** is freeware: free to use and to pass on unchanged, but
  not to modify or sell. The full terms are in `LICENSE.txt` in the
  download.

Both come without any warranty.

World of Warcraft is a trademark of Blizzard Entertainment, Inc. Raidex Keys is
not affiliated with Blizzard.
