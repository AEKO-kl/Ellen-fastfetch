<div align="center">

# Ellen-fastfetch

Une config [fastfetch](https://github.com/fastfetch-cli/fastfetch) aux couleurs d'Ellen (Zenless Zone Zero), pour **kitty** + **fish**.
Logo ASCII en étoile, cadres de texte, et des images d'Ellen posées par-dessus le terminal.

![preview](Ellen-fastfetch/Pictures/)

</div>

---

## Sommaire

- [Aperçu](#aperçu)
- [Prérequis](#prérequis)
- [Contenu du dépôt](#contenu-du-dépôt)
- [Installation](#installation)
- [Configuration de fish](#configuration-de-fish)
- [Régler les images](#régler-les-images)
- [Ajouter une image](#ajouter-une-image)
- [Personnalisation](#personnalisation)
- [Dépannage](#dépannage)
- [Crédits](#crédits)

---

## Aperçu

À chaque ouverture du terminal, fish lance fastfetch avec `Ellenconfig.jsonc` :

- un **logo ASCII** rose et blanc (`ascii-etoile.txt`) ;
- des **cadres** en caractères de dessin (┌ ─ ┐ │ └ ┘) avec trois blocs : *Welcome back!*, *Soft-and Hardware* et *Intelligence Agency (I.A)* ;
- des **images d'Ellen** (`Ellen2-trim.png` et `sitpose-trim.png`) affichées par-dessus le texte avec `kitten icat`.

Les images se replacent toutes seules selon la taille de la fenêtre (petite, moyenne, plein écran) et se redessinent quand tu redimensionnes le terminal.

---

## Prérequis

| Outil | Pourquoi |
|---|---|
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | affiche les infos système |
| [kitty](https://sw.kovidgoyal.net/kitty/) | seul terminal qui gère `kitten icat` avec la position et le z-index utilisés ici |
| [fish](https://fishshell.com/) | le script de lancement et de placement des images est écrit en fish |
| Une [Nerd Font](https://www.nerdfonts.com/) | rendu correct des cadres et du symbole ⛩ |

Sur Arch Linux :

```bash
sudo pacman -S fastfetch kitty fish
```

> Les images ne s'affichent pas dans un autre terminal que kitty. Le texte de fastfetch fonctionne partout.

---

## Contenu du dépôt

```
Ellen-fastfetch/
├── Ellenconfig.jsonc          # config fastfetch (cadres, modules, couleurs)
├── DEV-Ellen-config.fish      # lancement de fastfetch + placement des images (fish)
├── Terminal_Ellen/
│   ├── ascii-etoile.txt       # logo ASCII en couleur
│   ├── Ellen2-trim.png        # image d'Ellen (en haut à droite)
│   ├── sitpose-trim.png       # Ellen assise sur le cadre
│   └── ...                    # autres images disponibles
├── screenshots/
│   └── preview.png            # capture pour ce README
└── README.md
```

---

## Installation

### 1. Récupérer le dépôt

```bash
git clone https://github.com/AEKO-kl/Ellen-fastfetch.git
cd Ellen-fastfetch
```

### 2. Copier les fichiers dans la config fastfetch

Les chemins de la config pointent vers `~/.config/fastfetch/Terminal_Ellen/`, il faut donc copier les fichiers à cet endroit précis.

```bash
mkdir -p ~/.config/fastfetch
cp Ellenconfig.jsonc ~/.config/fastfetch/
cp -r Terminal_Ellen ~/.config/fastfetch/
```

> Cette commande n'écrase que `Ellenconfig.jsonc` et `Terminal_Ellen/`. Si tu as déjà un fichier du même nom, fais-en une copie avant.

### 3. Tester sans rien modifier

```bash
fastfetch -c ~/.config/fastfetch/Ellenconfig.jsonc
```

Tu dois voir le logo, les cadres et les infos de ta machine. Les images d'Ellen n'apparaissent qu'après l'étape suivante.

---

## Configuration de fish

Le fichier `DEV-Ellen-config.fish` contient deux choses :

1. des réglages personnels (starship, alias, couleurs quickshell...) que tu n'as pas besoin de copier ;
2. la section **« AUTO launch fastfetch + images posées par-dessus (kitty) »**, c'est elle qui t'intéresse.

### Option A : ajouter la section à ton `config.fish`

Ouvre `~/.config/fish/config.fish` et colle à la fin tout ce qui suit la ligne :

```fish
#  AUTO launch fastfetch + images posées par-dessus (kitty)
```

(jusqu'à la fin du fichier).

### Option B : fichier séparé

```bash
cp DEV-Ellen-config.fish ~/.config/fish/conf.d/ellen-fastfetch.fish
```

Dans ce cas, supprime du fichier copié la première partie (starship, alias, etc.) si elle ne correspond pas à ton installation, pour éviter les doublons ou des erreurs.

### Choisir l'affichage

Dans la section « lancement » :

```fish
set -g fetch_mode Ellenconfig
```

- `Ellenconfig` : charge `~/.config/fastfetch/Ellenconfig.jsonc` et pose les images ;
- `ascii` : charge `~/.config/fastfetch/config-ascii.jsonc`, sans images (ce fichier n'est pas fourni dans ce dépôt).

Ouvre ensuite un nouveau terminal kitty : fastfetch se lance et les images apparaissent.

---

## Régler les images

Les images sont positionnées à la main pour chaque taille de fenêtre. Pour connaître la taille de ton terminal (lignes puis colonnes) :

```bash
stty size
```

### Les trois tailles

| Mode | Condition (colonnes × lignes) |
|---|---|
| `big` (plein écran) | colonnes ≥ `big_cols` **et** lignes ≥ `big_rows` (150 × 40 par défaut) |
| `mid` (moyenne) | colonnes ≥ `mid_cols` **et** lignes ≥ `mid_rows` (101 × 37 par défaut) |
| `small` | tout le reste |

Tu peux changer ces seuils en haut de la section :

```fish
set -g big_cols 150
set -g big_rows 40
set -g mid_cols 101
set -g mid_rows 37
```

### Les réglages d'une image

Pour chaque image (ici `ellen`) et chaque taille (`big`, `mid`, `small`) :

```fish
set -g ellen_big_x 79   # position horizontale (colonnes depuis la gauche)
set -g ellen_big_y 1    # position verticale (lignes depuis le haut)
set -g ellen_big_w 26   # largeur maximale
set -g ellen_big_h 7    # hauteur maximale
```

- `x` et `y` : un nombre **négatif** colle l'image au bord droit ou bas (`-1` = collé, `-3` = marge de 2).
- `w` et `h` : taille maximale, l'image garde ses proportions.
- `ellen_z` / `sitpose_z` : `1` ou plus place l'image **au-dessus** du texte, `-1` **derrière** le texte. Une valeur plus grande passe au-dessus d'une plus petite.

Fais un réglage, ouvre un nouveau terminal (ou redimensionne la fenêtre) et regarde le résultat.

---

## Ajouter une image

1. Copie ton image dans `~/.config/fastfetch/Terminal_Ellen/`.
2. Ajoute un préfixe dans la liste (la dernière image de la liste est dessinée au-dessus) :
   ```fish
   set -g overlay_images ellen sitpose monimage
   ```
3. Copie un bloc de réglages et renomme les variables avec ton préfixe :
   ```fish
   # ---------- Mon image ----------
   set -g monimage_img ~/.config/fastfetch/Terminal_Ellen/mon-image.png
   set -g monimage_z 1
   set -g monimage_big_x 10
   set -g monimage_big_y 5
   set -g monimage_big_w 20
   set -g monimage_big_h 8
   set -g monimage_mid_x 10
   set -g monimage_mid_y 5
   set -g monimage_mid_w 15
   set -g monimage_mid_h 6
   set -g monimage_small_x 5
   set -g monimage_small_y -3
   set -g monimage_small_w 12
   set -g monimage_small_h 5
   ```

> Utilise de préférence des PNG avec fond transparent, recadrés au plus près du personnage (suffixe `-trim` dans ce dépôt).

---

## Personnalisation

| Ce que tu veux changer | Où |
|---|---|
| Le logo ASCII | `Terminal_Ellen/ascii-etoile.txt` (ou la ligne `"source"` dans `Ellenconfig.jsonc`) |
| La couleur rose des titres | `{##FA239B}` dans les lignes `custom` de `Ellenconfig.jsonc` |
| Les couleurs des étiquettes (OS, CPU...) | `"keyColor"` de chaque module |
| La couleur des cadres | `{#90}` (gris) dans les `format` |
| Les modules affichés | la liste `"modules"` (types disponibles : voir `fastfetch --list-modules`) |
| Le titre « Terminal » | la ligne `「Terminal」` en haut de `Ellenconfig.jsonc` |

> Les cadres sont dessinés à la main avec des espaces. Si tu modifies une valeur (nom du CPU, du GPU, etc.), ajuste les `<` et `>` dans le `format` pour que la bordure droite reste alignée.

---

## Dépannage

**Le logo ASCII n'apparaît pas.**
Vérifie que le fichier existe : `ls ~/.config/fastfetch/Terminal_Ellen/ascii-etoile.txt`. Le chemin est écrit dans `Ellenconfig.jsonc`, à la ligne `"source"`.

**Les images n'apparaissent pas.**
- Tu dois être dans **kitty** (pas dans un autre terminal, ni dans un TTY).
- Vérifie que les PNG existent dans `~/.config/fastfetch/Terminal_Ellen/`.
- Teste à la main : `kitten icat ~/.config/fastfetch/Terminal_Ellen/Ellen2-trim.png`.

**Les images sont mal placées.**
Relève la taille de ta fenêtre avec `stty size`, repère le mode correspondant (`small`, `mid`, `big`) et ajuste les valeurs `x`, `y`, `w`, `h` de ce mode.

**Les cadres sont décalés.**
Une police sans les caractères de dessin ou une valeur trop longue (nom du CPU, du GPU...) fait déborder la ligne. Change de police ou ajuste les `<` / `>` dans le `format` du module.

**`Config introuvable` au lancement.**
Le nom dans `set -g fetch_mode ...` doit correspondre à un fichier `~/.config/fastfetch/<nom>.jsonc`.

---

## Crédits

- [fastfetch](https://github.com/fastfetch-cli/fastfetch) pour l'outil.
- [kitty](https://sw.kovidgoyal.net/kitty/) et `kitten icat` pour l'affichage des images.
- Ellen Joe et *Zenless Zone Zero* appartiennent à HoYoverse. Les images utilisées ici sont des illustrations de fans ou des visuels du jeu, droits réservés à leurs auteurs. Si tu es l'auteur d'une image et que tu souhaites qu'elle soit retirée ou créditée, ouvre une issue.

---

<div align="center">

Fait par [AEKO-kl](https://github.com/AEKO-kl)

</div>
