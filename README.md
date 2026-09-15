<p align="center">
  <img src="https://raw.githubusercontent.com/incudex/raidex-keys/main/.github/assets/addon-icon.png" width="128" height="128" alt="Raidex Keys icon">
</p>

<h1 align="center">Raidex Keys</h1>

<p align="center">
  <em>Deine Mythic+-Woche im Blick – ohne das Spiel zu verlassen.</em><br>
  <em>Your Mythic+ week at a glance – without leaving the game.</em>
</p>

<p align="center">
  <a href="https://github.com/incudex/raidex-keys/releases"><b>Download</b></a> ·
  <a href="https://github.com/incudex/raidex-keys/issues/new/choose">Report a bug</a> ·
  <a href="https://raidex.app/keys/">raidex.app/keys</a>
</p>

<p align="center">
  <a href="https://github.com/incudex/raidex-keys/releases"><img alt="newest release" src="https://img.shields.io/github/v/release/incudex/raidex-keys?include_prereleases&label=download&color=7C5CFF"></a>
  <a href="https://github.com/incudex/raidex-keys/tree/main/addon/RaidexKeys"><img alt="World of Warcraft 12.1.0" src="https://img.shields.io/badge/WoW-retail%2012.1.0-B8873B"></a>
  <a href="https://github.com/incudex/raidex-keys/blob/main/LICENSE"><img alt="licence" src="https://img.shields.io/badge/licence-GPL--3.0--or--later-2C7BB6"></a>
  <a href="https://raidex.app/keys/"><img alt="languages" src="https://img.shields.io/badge/languages-DE%20%C2%B7%20EN-3B7DD8"></a>
  <a href="https://raidex.app"><img alt="made with love in Europe" src="https://img.shields.io/badge/made%20with%20%3C3%20in-Europe-003399"></a>
</p>

A World of Warcraft addon for Mythic+: the keystones, ratings, best runs and
Great Vault of all your characters, your group's and your guild's keys, the
runs to your next rating goal, your guild's key board, a raid calendar with
sign-ups and a Mythic+ timer - all in game. Part of the [Raidex](https://raidex.app) family.

<p align="center">
  <img src="https://raw.githubusercontent.com/incudex/raidex-keys/main/.github/assets/addon-window.png" width="440" alt="The addon's window: your guild's keys this week, grouped by dungeon">
  <img src="https://raw.githubusercontent.com/incudex/raidex-keys/main/.github/assets/addon-timer.png" width="440" alt="The addon's Mythic+ timer during a key">
</p>

More pictures on [raidex.app/keys](https://raidex.app/keys/#einblicke).

This repository hosts the **releases**, the **issue tracker** and the
**addon** ([`addon/RaidexKeys`](https://github.com/incudex/raidex-keys/tree/main/addon/RaidexKeys)), in the form WoW loads it.

## What it brings

- **A window** with six tabs. *Guild*: your guild's keys this week, grouped
  by dungeon. *Alts*: every character's key, this week's runs, Great Vault
  and rating - an alt is in it without logging it in. *Group*: the keys of
  the group you are in. *Rating goals*: the fewest runs that lift you to 2500,
  3000 and 3500 rating, each at the lowest level that does it, and who in your
  alts, group or guild holds a key for it. *Board*: your guild's key board.
  *Raids*: your guild's raid calendar. Left open, the window is back after a
  `/reload` or a loading screen.
- **The key board**: pin your key for a day and a time, with a note such as
  "a few more keys afterwards". Guild members sign up as tank, healer or
  damage, up to ten, counted against a group of five - so you can still talk
  it over with those who come too late; a click on a name whispers them. The
  board travels through your guild's addon channel and reaches members who
  were offline when the key was pinned.
- **The raid calendar**: the raids your guild enters in the game's calendar,
  today and the next two weeks, with a sign-up as tank, healer or DPS and a
  note of your own. Signing up here signs you up in the game's calendar too.
  A raid shows who is in - counted by role, with item level and note -, its
  difficulty and how far your guild is in it, from the guild's achievements.
  The raid's creator, a moderator or the guild master sets anyone's role.
- **A Mythic+ timer** while a key runs: the time left with the +2 and +3
  limits, every boss with the time it fell and your best time, the enemy
  forces to two decimals, the deaths and what they cost, and where your rating
  would land if the run ended now. After every boss your own chat says when it
  fell; at the end the key's holder tells the group how it went. Nothing is
  said at the start.
- **A minimap button** whose tooltip shows your key, how many keys of your
  group are known and how many keys your guild has this week. A click opens
  the window, shift-click the options, ctrl-click shows or hides the timer,
  right-click links your key in the chat.
- **Options** under *Options → AddOns → Raidex Keys*: sharing your key with
  the guild, five colour themes, the fonts and sizes of the window and the
  timer, a grid to line them up, and what the timer shows, says and looks
  like. The addon speaks your client's language, German or English.

## Download

Get the [newest release](https://github.com/incudex/raidex-keys/releases);
what changed in each one is in the
[changelog](https://github.com/incudex/raidex-keys/blob/main/CHANGELOG.md).
A release contains:

| File | What it is |
|---|---|
| `raidex-keys-addon-<version>.zip` | the addon. Unpack it into `World of Warcraft/_retail_/Interface/AddOns`, so that the folder `RaidexKeys` lands there. |
| `SHA256SUMS` | the checksum of the file above |
| Source code (zip, tar.gz) | the addon as of this release, added by GitHub |

WoW saves the addon's data when you log out or type `/reload`.

## Your data

The addon sends nothing to a server. It keeps what it records in its
SavedVariables, a file on your own disk. The key board and the raid sign-ups
go to your guild members' addons only, through the game's addon channel; a
raid sign-up is also set in the game's own calendar.

## Getting along with other addons

LibKeystone is **not shipped**. If another addon such as BigWigs has already
loaded it, Raidex Keys uses that one, so nobody answers twice; otherwise the
addon speaks the protocol itself. Astral Keys and its relatives can stay where
they are.

## Report a bug or suggest something

[Open an issue](https://github.com/incudex/raidex-keys/issues/new/choose). You
can write in German or English.

## Licence

Copyright © 2026 incūdex, Lars Gossard · <raidex@incudex.de>

Raidex Keys is free software: you can redistribute it and/or modify it under
the terms of the [GNU General Public License](https://github.com/incudex/raidex-keys/blob/main/LICENSE)
as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version. It comes without any
warranty.

World of Warcraft is a trademark of Blizzard Entertainment, Inc. Raidex Keys is
not affiliated with Blizzard.
