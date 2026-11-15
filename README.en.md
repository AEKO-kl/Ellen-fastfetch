<div align="center">

🇬🇧 English · [🇫🇷 Français](README.md)

# Ellen-fastfetch

**A fastfetch setup themed after Ellen Joe (Zenless Zone Zero), for kitty + fish.**
ASCII logo, text frames, and Ellen images overlaid on top of your terminal.

![preview](Pictures/preview.png)

</div>

---

## What you get

- A pink and white **ASCII logo** shaped like a star.
- Three **frames**: *Welcome back!*, *Soft-and Hardware* (OS, CPU, BIOS, GPU, RAM, disks) and *Intelligence Agency* (login, uptime, local IP, date, mouse).
- Two **Ellen images** drawn over the text. They reposition themselves depending on your window size and redraw when you resize it.
- Everything shows up **every time you open a terminal**.
- Optionally, a script to adjust **kitty's transparency**.

---

## Quick install

Requirements: [kitty](https://sw.kovidgoyal.net/kitty/), [fish](https://fishshell.com/) and [fastfetch](https://github.com/fastfetch-cli/fastfetch). On Arch Linux, the install script takes care of them:

```bash
git clone https://github.com/AEKO-kl/Ellen-fastfetch.git
cd Ellen-fastfetch
bash install.sh --deps
```

`--deps` installs kitty, fish and fastfetch with pacman (it asks for your sudo password). If you already have them, or you're not on Arch, just run `bash install.sh`.

Then open a **new kitty terminal** running fish: fastfetch starts and Ellen shows up.

> If your `config.fish` already launches fastfetch, remove that line: otherwise it will be displayed twice.

### Script options

| Command | Effect |
|---|---|
| `bash install.sh` | installs the config, the images and the fish script |
| `bash install.sh --deps` | also installs kitty, fish and fastfetch (Arch Linux, via pacman) |
| `bash install.sh --transparency 0.6` | installs and turns on kitty transparency (from `0.2` to `1.0`, `0.60` if you leave the value out) |
| `bash install.sh --uninstall` | removes everything, transparency included |
| `bash install.sh --help` | shows the help |

Options can be combined: `bash install.sh --deps --transparency 0.7`.

### What the script does

- It copies `Ellenconfig.jsonc` and `Terminal_Ellen/` into `~/.config/fastfetch/`.
- It copies `ellen-fastfetch.fish` into `~/.config/fish/conf.d/`.
- If one of those files already exists with different content, it keeps a copy (`.bak-ellen-<date>`) before replacing it.
- It touches neither your `config.fish` nor your `kitty.conf`, unless you ask for transparency.
- You can run it as many times as you like: use it to update after a `git pull`.

### Your shell isn't fish?

Two options:

- Just type `fish` in kitty to try it out.
- Or make fish your default shell: `chsh -s /usr/bin/fish` (you need to log out and back in).

### Try it without fish or images

The fastfetch text output works in any terminal:

```bash
fastfetch -c ~/.config/fastfetch/Ellenconfig.jsonc
```

The Ellen images, however, only display in **kitty** (they rely on `kitten icat`).

### Manual install

<details>
<summary>Without the install script</summary>

```bash
git clone https://github.com/AEKO-kl/Ellen-fastfetch.git
cd Ellen-fastfetch

mkdir -p ~/.config/fastfetch ~/.config/fish/conf.d
cp -r Ellenconfig.jsonc Terminal_Ellen ~/.config/fastfetch/
cp ellen-fastfetch.fish ~/.config/fish/conf.d/
```

These commands only overwrite `Ellenconfig.jsonc`, the `Terminal_Ellen/` folder and `ellen-fastfetch.fish`.

</details>

### Uninstall

From the cloned folder:

```bash
bash install.sh --uninstall
```

This removes `ellen-fastfetch.fish`, `Ellenconfig.jsonc`, the `Terminal_Ellen/` folder (**including any images you added to it**) and transparency if it is on. The `.bak-ellen-*` backups are not deleted.

<details>
<summary>By hand</summary>

```bash
rm ~/.config/fish/conf.d/ellen-fastfetch.fish
rm ~/.config/fastfetch/Ellenconfig.jsonc
rm -r ~/.config/fastfetch/Terminal_Ellen
bash ellen-transparency.sh --off   # only if you turned transparency on
```

</details>

---

## Font

The frames use box-drawing characters (┌ ─ ┐ │ └ ┘) and the ⛩ symbol. Use a **monospace** font that supports them, preferably a [Nerd Font](https://www.nerdfonts.com/) (for example JetBrains Mono Nerd Font). Without one, the borders may be misaligned.

---

## Transparency (optional)

The `ellen-transparency.sh` script makes kitty's background transparent. Run it from the cloned folder:

```bash
bash ellen-transparency.sh 0.6      # turn transparency on
bash ellen-transparency.sh          # same, with the default value (0.60)
bash ellen-transparency.sh --off    # turn transparency off
```

Shortcut: `bash install.sh --transparency 0.6` does the install and turns transparency on in a single command.

The value ranges from `0.2` (very transparent) to `1.0` (opaque). Below `0.2` the text becomes unreadable, so the script refuses.

What the script does:

- it creates the file `~/.config/kitty/ellen-transparency.conf` (`background_opacity` and `dynamic_background_opacity yes`);
- it adds the line `include ellen-transparency.conf` **at the end** of your `kitty.conf`, so it takes priority;
- it keeps a copy of your original file as `kitty.conf.bak-ellen` (created only once);
- it asks kitty to reload its configuration.

**The first time**, close and reopen kitty if the transparency doesn't show up right away.

To use another value, just run the command again: `kitty.conf` doesn't get duplicate lines. `--off` removes the file and the `include` line, the rest of your config is left untouched.

> On Hyprland, the blur behind the terminal is handled by Hyprland (`blur` setting), not by this script.

---

## Repository contents

```
Ellen-fastfetch/
├── Ellenconfig.jsonc        # fastfetch config (frames, modules, colors)
├── ellen-fastfetch.fish     # launches fastfetch + places the images
├── install.sh               # installer (dependencies, files, transparency)
├── ellen-transparency.sh    # (optional) adjusts kitty transparency
├── Terminal_Ellen/
│   ├── ascii-etoile.txt     # colored ASCII logo
│   ├── Ellen2-trim.png      # Ellen image (top right)
│   ├── sitpose-trim.png     # Ellen sitting on the frame
│   └── ...                  # other available images
├── Pictures/
│   └── preview.png
├── README.md                # French
└── README.en.md             # English
```

---

## Adjusting the images

The images are placed by hand for three window sizes. The settings are at the top of `~/.config/fish/conf.d/ellen-fastfetch.fish`.

To find your terminal size (rows then columns):

```bash
stty size
```

### The three modes

| Mode | Condition |
|---|---|
| `big` (fullscreen) | columns ≥ 150 **and** rows ≥ 40 |
| `mid` (medium) | columns ≥ 101 **and** rows ≥ 37 |
| `small` | everything else |

You can change the thresholds with `big_cols`, `big_rows`, `mid_cols` and `mid_rows`.

### Settings for one image

For each image (here `ellen`) and each mode (`big`, `mid`, `small`):

```fish
set -g ellen_big_x 79   # horizontal position (columns from the left)
set -g ellen_big_y 1    # vertical position (rows from the top)
set -g ellen_big_w 26   # maximum width
set -g ellen_big_h 7    # maximum height
```

- `x`, `y`: a **negative** number sticks the image to the right or bottom edge (`-1` = flush, `-3` = 2-cell margin).
- `w`, `h`: maximum size, the image keeps its proportions.
- `ellen_z` / `sitpose_z`: `1` or more draws the image **above** the text, `-1` **behind** it.

After changing a setting, open a new terminal (or resize the window) to see the result.

---

## Adding your own image

1. Copy your PNG (transparent background, cropped tightly) into `~/.config/fastfetch/Terminal_Ellen/`.
2. Add a prefix to the list (the last image is drawn on top):
   ```fish
   set -g overlay_images ellen sitpose myimage
   ```
3. Add a settings block using that prefix:
   ```fish
   # ---------- My image ----------
   set -g myimage_img ~/.config/fastfetch/Terminal_Ellen/my-image.png
   set -g myimage_z 1
   set -g myimage_big_x 10
   set -g myimage_big_y 5
   set -g myimage_big_w 20
   set -g myimage_big_h 8
   set -g myimage_mid_x 10
   set -g myimage_mid_y 5
   set -g myimage_mid_w 15
   set -g myimage_mid_h 6
   set -g myimage_small_x 5
   set -g myimage_small_y -3
   set -g myimage_small_w 12
   set -g myimage_small_h 5
   ```

---

## Customizing the text

Everything happens in `~/.config/fastfetch/Ellenconfig.jsonc`.

| What you want to change | Where |
|---|---|
| The ASCII logo | the file `Terminal_Ellen/ascii-etoile.txt`, or the `"source"` line |
| The pink of the titles | `{##FA239B}` in the `custom` lines |
| The label colors (OS, CPU...) | `"keyColor"` of each module |
| The frame color | `{#90}` (gray) in the `format` strings |
| The displayed modules | the `"modules"` list (see `fastfetch --list-modules`) |
| The "Terminal" title | the `「Terminal」` line at the top of the file |

> The frames are drawn by hand with spaces. If you change a module, adjust the `<` and `>` in its `format` so the right border stays aligned.

---

## Troubleshooting

**The images don't show up.**
You must be in **kitty** (not another terminal, and not a TTY). Check that the PNG files exist in `~/.config/fastfetch/Terminal_Ellen/`, then test by hand:

```bash
kitten icat ~/.config/fastfetch/Terminal_Ellen/Ellen2-trim.png
```

**The ASCII logo doesn't show up.**
Check that `~/.config/fastfetch/Terminal_Ellen/ascii-etoile.txt` exists. If the `~` path isn't handled on your system, replace it with your full path on the `"source"` line of `Ellenconfig.jsonc` (for example `/home/your-name/.config/fastfetch/Terminal_Ellen/ascii-etoile.txt`).

**Nothing launches when I open the terminal.**
Make sure you are in fish (`echo $SHELL` or `fish`) and that the file is in place: `ls ~/.config/fish/conf.d/ellen-fastfetch.fish`.

**The images are misplaced.**
Check your window size with `stty size`, find the matching mode (`small`, `mid`, `big`) and adjust `x`, `y`, `w`, `h` for that mode.

**The frames are misaligned.**
Switch fonts, or shorten the value involved (CPU name, GPU name...) using `<` / `>` in the module's `format`.

**Transparency doesn't change anything.**
Close and reopen kitty (required the first time). If nothing changes, another `background_opacity` line placed after the `include` may be overriding it: `grep -rn background_opacity ~/.config/kitty`. Also check that your compositor supports transparency (Hyprland does by default).

**`Config introuvable` message.**
The name in `set -g fetch_mode Ellenconfig` must match a file `~/.config/fastfetch/<name>.jsonc`. (The message is in French: it means "config not found".)

---

## Credits

- [fastfetch](https://github.com/fastfetch-cli/fastfetch) for the tool.
- [kitty](https://sw.kovidgoyal.net/kitty/) and `kitten icat` for image display.
- Ellen Joe and *Zenless Zone Zero* belong to HoYoverse. The images are fan illustrations or game visuals, all rights reserved to their authors. If you are the author of an image and want it removed or credited, please open an issue.

---

<div align="center">

Made by [AEKO-kl](https://github.com/AEKO-kl) · A star ⭐ is always appreciated

</div>
