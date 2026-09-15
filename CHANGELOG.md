# Changelog

What changed in each release of the Raidex Keys addon. The files are on
[GitHub releases](https://github.com/incudex/raidex-keys/releases).

## 0.6.0 – 2026-09-15

- A **raid calendar** in the new tab *Raids*: the raids your guild enters in
  the game's calendar as guild events of the type raid, today and the next two
  weeks, with a sign-up as tank, healer or damage dealer - which the game's
  calendar cannot. Signing up here signs you up in the game's calendar too,
  and taking it back takes it back there. Whoever is signed up in the game's
  calendar shows up as well, without a role until the raid's creator, a
  moderator or the guild master picks one - a click on a name offers the
  three - and they can change any role that way. A click on a raid shows who is in, counted
  as tanks, healers and damage, in a table of name - its creator with a crown - role with its icon and item level,
  under the raid's title the raid and its difficulty with the guild's progress
  in it, as the guild's achievements tell it (3/8), and the note of the
  game's event. Your sign-up takes a note of its own, such as "I have to leave
  early"; a sign-up's note shows in the status bar when the mouse is on it. A
  button per role signs you up or changes your role, and a click on a name
  whispers them. The sign-ups travel through your guild's addon channel, as
  the key board's postings do. The list shows each raid's difficulty, under
  its title the raid's name, and under that a square for every boss - filled
  for those your guild has down.
- The tabs are a little narrower, so six fit beside "Post your key".
- The Mythic+ timer **says nothing at the start** of a key any more: the game
  swallowed "Raidex Keys loaded for …" and "Timer started …" anyway. The end
  still reaches the group; the option is now called "The run's end in the
  group chat". **Put away, the timer says nothing**: no boss times, no end.
- The Mythic+ timer **switched off in the options stays off**. The next key
  turned it on again, and its chat lines with it (a player's report). A
  shift-click on the timer or a ctrl-click on the minimap button still hides
  it only until the next key.
- A ctrl-click on the minimap button **hides and shows the timer without a
  line in the chat**.
- A timer switched off in the options **keeps no boss times from the chest**:
  it wrote the time of the chest as every open boss's best time.
- The options' **Defaults** button leaves the affixes off, as the timer ships,
  and puts the preview's level back to +12.
- The mouse wheel over an open posting of the key board **no longer scrolls
  the list behind it**.
- Closing the window with Escape **ends `/rk preview`** as its button does.

## 0.5.0 – 2026-09-15

- Five **colour themes** for the window, the key board, the timer and the
  minimap tooltip: Raidex as before, Nord — Polar Night, Ember, Verdant and
  Slate. Choosing one sets the timer's background and text colour to match;
  both can be changed afterwards.
- **More fonts**, the same list for the window and the timer, each chosen on
  its own: PT Sans Narrow now ships with the addon, and Expressway, Homespun,
  Continuum Medium, Die Die Die! and Action Man appear when ElvUI or a
  SharedMedia addon provides them.
- **Pick your main** in the Alts tab: click a character and confirm, and the
  rating goals are planned on its runs instead of the character you are
  logged in with; the main wears the glow edge in the list. The timer stays
  with the logged-in character.
- The key board's **times and days read as you choose** (Options -> AddOns ->
  Raidex Keys -> Window): the clock as the game's own clock is set, 24 or 12
  hours; the day as your game's language writes it, 13.09., 09/13 or
  2026-09-13.
- The key board **counts the key holder in**: a fresh posting reads 1/5, and
  four sign-ups make the group full.
- **Every column sorts** in the Alts, Group and Guild tabs, Week, Vault and
  Updated included; figures and times start with the most. Your own
  character no longer stays at the top whatever the order, and the arrow
  stands beside its own head - on Rating it stood by Updated.
- Sorted by dungeon, the Guild tab **keeps its Dungeon column**, head and
  arrow included, so a second click turns the groups around. The head used
  to vanish.
- The **Group tab is greyed out** while you are in no group.
- **Buttons look like buttons**, on a face of their own inside a thin edge.
  "Click a name to whisper." is gone; a click on a name still whispers.
- The hint "Right-click: link key in chat" is gone from the minimap tooltip
  and the window; a right-click still links the key. "Every run in time" is
  gone from the goals' footer, which names the character instead.
- The **tabs stand on a bar** of their own, with more room over and under
  them, and light up under the mouse.

## 0.4.1 – 2026-09-13

- The **key board** shows its times in **realm time**, as the game's calendar
  does. A member whose computer stood in another time zone saw every posting
  an hour off - 21:15 for 22:15. Late in the evening, the form now opens on
  tomorrow instead of on today's small hours.
- The **group tab** shows the keys of group members the guild already told
  this week, not only the answers from the group itself - and asks the group
  again after a /reload.

## 0.4.0 – 2026-09-13

- A new **Rating goals** tab: the fewest runs that lift your
  character to 2500, 3000 and 3500 M+ rating, each at the lowest level that
  does it, with what each adds - and who holds a key for it: your alts, your
  group or your guild.
- The **Board** tab is your guild's key board. Pin your key for a day and a
  time with a note - "a few more keys afterwards" - and guild members sign up
  for it, as tank, healer or damage, ten at most, so you can still talk it
  over with those who come too late. The count reads against a group of five -
  yellow below it, green at 5/5, red when more have signed up, as in 7/5. A click on a name whispers them. The
  board travels through the guild's addon channel, so it reaches members who
  were offline when a key was pinned; no server is involved.
- The **window stays open** over a `/reload` and a loading screen when you
  left it open. Closed with its button, Escape or the minimap, it stays closed.
  Guild names **wear their class colour at once**: the classes from the guild
  roster are kept, where they stood white for seconds after every `/reload`.
- The **rating column's head fits**: the German "WERTUNG" and the board's "SIGNED UP"
  were wider than their column and cut short.
- The key's **start is said to you** now, not to the group: during a key the
  game keeps addons out of the group chat, and the lines never arrived.
  Everyone with the addon reads it - the key's holder with the key linked.
- The **end reaches the group** again: the holder's "Well done!" or "Maybe next
  time!" waits until the game lets addons speak after the chest, a minute at
  most.
- At the chest **no boss is announced twice**: the game stops the run's clock
  just before it says the run is done, and the timer took that for a new run -
  every boss came again with the final time, and the card showed that time for
  each.
- The addon has a **window** of its own now, as the design draws it: the tabs
  Alts, Group and Guild over one table - character, dungeon, key, this
  week's runs, the Great Vault and the M+ rating, the biggest key first. Over
  it stand the week's affixes and how long it is until the reset. A left-click
  on the minimap button opens it (the options moved to shift-click), and so
  does `/rk window`. It reads what is stored, so every alt is in it without
  logging in.
- The **column heads sort** the table - a second click turns the order around
  - and the Guild tab, sorted by dungeon, **groups the keys under it**, with
  how many stand there. A click on a tab puts its order back.
- The Alts tab shows **this week's runs** as a small square each, filled
  where the key was timed, and beside the Great Vault slots the **item level**
  its best unlocked slot would give. Every tab says **how long ago** a row was
  last heard of.
- **Your own character stands first** and wears the violet edge, in Alts and
  in Group.
- A **right-click on a row** puts its key into the chat: your own as the link
  out of your bags, anyone else's as name, dungeon and level.
- The window's **font is yours to pick** (Options -> AddOns -> Raidex Keys):
  Marcellus, the face it was designed in and which now ships with the addon,
  or the game's Friz Quadrata or Arial Narrow. Its **size** is yours as well:
  a font size in the options that takes rows, columns and the window along,
  and a **grip** in the lower right corner that drags the window bigger or
  smaller - never below what its columns need.
- While the options stand open, the timer's preview can show **any dungeon
  of the season at any level**, or a line of letters with umlauts, to see what
  the chosen font makes of them.
- **The run speaks in the chat.** When the timer starts, the key is linked in the group chat -
  "Raidex Keys loaded for [Keystone: The Blinding Vale (9)]", by whoever
  holds it, so it comes once however many run the addon - and the group reads
  "Timer started, 30 minutes left – Have a great run!";
  after every boss you alone read when it fell and where your M+ rating would
  land, with what that adds. At the end the key's holder tells the group
  "Well done! New keystone: [Keystone]" when the run was in time, or "Maybe
  next time!" when it was not. Both can be switched off in the options. While
  the game keeps addons out of the chat, as a running key can, the lines are
  shown to you instead of being refused.
- The window and the timer **move on a grid**: dragged, they go in steps of 10
  points and line up with each other. The step is set in the options - 20, 30,
  40, or off.
- The **options are grouped**: under AddOns -> Raidex Keys the window and the
  Mythic+ timer have pages of their own, and the timer's page is divided into
  what it does during a key, what it says in the chat, the preview and its
  look.
- The tabs read **Guild, Alts, Group**. The affixes over them are set
  small and stop before the countdown; the name and the dungeon have more room,
  and the window is a little wider for it. **Options** in the header
  can be clicked now - the frame that drags the window lay over it.
- The column heads **all show**: in game three of the four stood empty. The
  name and the dungeon share the room that is left - a name up to its realm,
  the dungeon the rest, and where no dungeon is on screen the name has it all
  and the numbers stand together at the right. A **scrollbar** stands beside a
  list longer than the window.
- The panel's **Defaults** puts back what is not a setting as well: where the
  timer, the window and the minimap button stand, and the timer's two colours.
  `/rk reset` does the same.
- The **Guild tab counts you in**: your own key stands beside the guild's,
  which means the tab holds real keys from the first day in a guild rather
  than sample values. Guild names wear their class colour now - a keystone
  message carries no class, so it comes from the guild roster - and opening
  the window asks the guild again, at most once a minute.
- The **footer says what is stored**, never what is on screen: it counts the
  characters, the group with the keys known in it, and the guild with its keys
  of the week. Where nothing is stored it says so - "No characters stored yet",
  "not in a group", "not in a guild".
- Two alts of the same name on different realms are told apart by the realm
  in the Alts tab.
- `/rk preview` shows **every surface with sample values at once** - window,
  minimap tooltip and Mythic+ timer - so the look can be judged and each piece
  dragged into place without a keystone, a group or a guild. A tab with
  nothing to show says **why it is empty** and where to go about it, rather
  than standing on made-up rows.
- The timer's look is **yours to set** (Options -> AddOns -> Raidex Keys):
  how much of the dungeon shows through it, the font out of the five the game
  ships, the size of the text, and the background and text colour. The grey
  tones follow the colours you pick, so one choice never leaves the rest
  behind, while the colours that mean something - the keystone level, the
  clock, the time deaths cost - stay where they are. The way back to the designed look,
  or `/rk reset`, puts the designed look back if a colour turns out
  unreadable.
- The ticks beside the bosses are **drawn** now, not written: Friz Quadrata
  has no glyph for them, so in game they were empty boxes.
- The Mythic+ timer wears the **design's card** now: a dark panel with a
  violet edge, rules between its parts, the clock as a bar with the +2 and +3
  limits marked on it, and the enemy forces with a bar of their own. Head and
  clock are set in the game's display face, Morpheus.
- A **Mythic+ timer**. While a keystone runs, it shows the level
  and the dungeon, the affixes, the time left with the limits for +2 and +3,
  every boss with the time it fell and your best time for it, the enemy forces
  to two decimals and the deaths with the time they cost. One line keeps
  telling you what the run would be worth if it ended this very moment - its
  dungeon rating, and how much it adds to your M+ rating over your best run
  there. Deaths so far are in that figure, since they are in the clock;
  whatever is still to come is not. Your best time per
  boss is kept per dungeon and key level, and a `/reload` in the middle of a
  run keeps the times already taken. The game's own timer is faded out while
  it shows. Both can be switched off in the options, and `/rk timer` shows a
  made-up run to drag the display where you want it.
- **The card stays up after the run.** The game drops the keystone the moment
  the chest appears, and the timer went with it - before you could read what
  the run took, what it was worth and what the deaths cost. It now stands as
  it stood until you leave the dungeon or start the next key.
- **"Hide the quest tracker"** (Options -> AddOns -> Raidex Keys): with it
  ticked, the tracked quests, campaigns and achievements go while a keystone
  runs and come back when it ends - the "All Objectives" bar with them, which
  is what is left standing over the card when nothing is tracked. The screen
  during a key is the key. It ships unticked, and leaves the game's own timer
  to the box above it.

## 0.1.12 – 2026-09-12

- Stores what each keystone level rewards this season. Midnight's client
  answers only the Great Vault's level, and only once it feels like it - the
  addon asks again until it does, and drops the table when a new season starts.
- `/rk` says how many reward levels are known, `/rk debug` what the game
  answers right now and what was stored from it.

## 0.1.9 – 2026-09-12

Initial release.

- Records keystone, rating, best runs and vault of every character.
- Collects guild keys over the LibKeystone protocol, as BigWigs does, and
  shares yours with your guild - switched off in its options, if you like.
- A minimap button: its tooltip shows your key, how many of your group's
  keys are known and how many your guild has this week; a right-click links
  your key in chat. `/rk minimap` hides or shows it.
- `/rk` tells what it has stored, `/rk options` opens its options.
