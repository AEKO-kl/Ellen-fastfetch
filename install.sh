#!/usr/bin/env bash
# =====================================================================
#  install.sh : installateur d'Ellen-fastfetch
#  https://github.com/AEKO-kl/Ellen-fastfetch
#
#  Usage :
#    bash install.sh                        installe la config, les images et le script fish
#    bash install.sh --deps                 installe aussi kitty, fish et fastfetch (Arch Linux)
#    bash install.sh --transparency [0.6]   active aussi la transparence de kitty (0.2 à 1.0)
#    bash install.sh --uninstall            désinstalle tout
#    bash install.sh --help                 affiche cette aide
#
#  Les options se combinent : bash install.sh --deps --transparency 0.7
# =====================================================================
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FF_DIR="$HOME/.config/fastfetch"
FISH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d"
KITTY_DIR="${KITTY_CONFIG_DIRECTORY:-${XDG_CONFIG_HOME:-$HOME/.config}/kitty}"

# --- affichage ---------------------------------------------------------
if [ -t 1 ]; then
  G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; B=$'\e[1m'; N=$'\e[0m'
else
  G=""; Y=""; R=""; B=""; N=""
fi
ok()   { printf '%s✓%s %s\n' "$G" "$N" "$*"; }
warn() { printf '%s!%s %s\n' "$Y" "$N" "$*"; }
err()  { printf '%s✗%s %s\n' "$R" "$N" "$*" >&2; }

usage() {
  sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,2\}//'
}

# --- options -----------------------------------------------------------
DEPS=0
TRANSP=0
TVAL=""
UNINSTALL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --deps) DEPS=1 ;;
    --transparency)
      TRANSP=1
      if [ $# -gt 1 ] && [[ "$2" =~ ^[0-9]*\.?[0-9]+$ ]]; then
        TVAL="$2"
        shift
      fi
      ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) usage; exit 0 ;;
    *) err "Option inconnue : $1"; echo >&2; usage >&2; exit 1 ;;
  esac
  shift
done

run_transparency() {
  if [ -n "$TVAL" ]; then
    bash "$SRC/ellen-transparency.sh" "$TVAL"
  else
    bash "$SRC/ellen-transparency.sh"
  fi
}

# --- désinstallation ---------------------------------------------------
if [ "$UNINSTALL" -eq 1 ]; then
  echo "${B}Désinstallation d'Ellen-fastfetch${N}"
  rm -f "$FISH_DIR/ellen-fastfetch.fish"
  ok "Script fish retiré"
  rm -f "$FF_DIR/Ellenconfig.jsonc"
  rm -rf "$FF_DIR/Terminal_Ellen"
  ok "Config et images retirées"
  if [ -f "$KITTY_DIR/ellen-transparency.conf" ] || grep -qs '^include ellen-transparency.conf$' "$KITTY_DIR/kitty.conf"; then
    if [ -f "$SRC/ellen-transparency.sh" ]; then
      bash "$SRC/ellen-transparency.sh" --off
    else
      warn "Transparence encore active : lance « ellen-transparency.sh --off » depuis le dossier cloné."
    fi
  fi
  echo
  echo "Terminé. Les éventuelles sauvegardes (*.bak-ellen-*) n'ont pas été supprimées."
  exit 0
fi

# --- vérification de la valeur de transparence (avant de copier quoi que ce soit)
if [ -n "$TVAL" ] && ! awk -v v="$TVAL" 'BEGIN { exit !(v + 0 >= 0.2 && v + 0 <= 1) }'; then
  err "Valeur de transparence invalide : « $TVAL ». Entre 0.2 et 1.0 (exemple : 0.6)."
  exit 1
fi

# --- vérification des fichiers sources ---------------------------------
echo "${B}Installation d'Ellen-fastfetch${N}"
for f in Ellenconfig.jsonc ellen-fastfetch.fish Terminal_Ellen/ascii-etoile.txt \
         Terminal_Ellen/Ellen2-trim.png Terminal_Ellen/sitpose-trim.png; do
  if [ ! -e "$SRC/$f" ]; then
    err "Fichier manquant dans le dépôt : $f"
    err "Lance ce script depuis le dossier Ellen-fastfetch cloné."
    exit 1
  fi
done
if [ "$TRANSP" -eq 1 ] && [ ! -f "$SRC/ellen-transparency.sh" ]; then
  err "ellen-transparency.sh est introuvable dans le dépôt."
  exit 1
fi

# --- dépendances -------------------------------------------------------
if [ "$DEPS" -eq 1 ]; then
  if command -v pacman >/dev/null 2>&1; then
    echo "Installation de kitty, fish et fastfetch (mot de passe sudo demandé)..."
    sudo pacman -S --needed kitty fish fastfetch
    ok "Dépendances installées"
  else
    warn "pacman introuvable : --deps ne fonctionne que sur Arch Linux."
    warn "Installe kitty, fish et fastfetch avec le gestionnaire de paquets de ta distribution."
  fi
fi

missing=()
for c in kitty fish fastfetch; do
  command -v "$c" >/dev/null 2>&1 || missing+=("$c")
done
if [ "${#missing[@]}" -gt 0 ]; then
  warn "Programmes manquants : ${missing[*]}"
  warn "Sur Arch Linux : bash install.sh --deps   (ou : sudo pacman -S ${missing[*]})"
else
  ok "kitty, fish et fastfetch sont installés"
fi

# --- copie des fichiers ------------------------------------------------
# copie un fichier ; sauvegarde l'ancien s'il existe avec un contenu différent
install_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && ! cmp -s "$src" "$dest"; then
    local bak="$dest.bak-ellen-$(date +%Y%m%d%H%M%S)"
    cp "$dest" "$bak"
    warn "Ancienne version sauvegardée : $bak"
  fi
  cp "$src" "$dest"
}

install_file "$SRC/Ellenconfig.jsonc" "$FF_DIR/Ellenconfig.jsonc"
ok "Config copiée : $FF_DIR/Ellenconfig.jsonc"

mkdir -p "$FF_DIR/Terminal_Ellen"
cp -r "$SRC/Terminal_Ellen/." "$FF_DIR/Terminal_Ellen/"
ok "Logo et images copiés : $FF_DIR/Terminal_Ellen/"

install_file "$SRC/ellen-fastfetch.fish" "$FISH_DIR/ellen-fastfetch.fish"
ok "Script fish copié : $FISH_DIR/ellen-fastfetch.fish"

# --- transparence (optionnel) ------------------------------------------
if [ "$TRANSP" -eq 1 ]; then
  run_transparency
fi

# --- conseils de fin ---------------------------------------------------
FISH_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
if grep -qs 'fastfetch' "$FISH_CONF"; then
  warn "Ton config.fish contient déjà « fastfetch » : retire cette ligne, sinon il s'affichera deux fois."
fi

echo
echo "${B}Terminé.${N} Ouvre un nouveau terminal kitty avec fish : fastfetch se lance et Ellen apparaît."
case "$(basename "${SHELL:-sh}")" in
  fish) ;;
  *) echo "Ton shell actuel n'est pas fish : tape « fish » dans kitty pour l'essayer," ;
     echo "ou fais-en ton shell par défaut avec : chsh -s \"\$(command -v fish)\"" ;;
esac
if [ "$TRANSP" -eq 0 ]; then
  echo "Envie de transparence ? bash install.sh --transparency 0.6"
fi
