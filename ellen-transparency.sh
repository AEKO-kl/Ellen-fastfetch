#!/usr/bin/env bash
# =====================================================================
#  ellen-transparency.sh : transparence du terminal kitty
#  https://github.com/AEKO-kl/Ellen-fastfetch
#
#  Usage :
#    bash ellen-transparency.sh 0.6      active la transparence (1 = opaque)
#    bash ellen-transparency.sh          idem, avec la valeur par défaut (0.60)
#    bash ellen-transparency.sh --off    retire la transparence
#
#  Valeurs : de 0.2 (très transparent) à 1.0 (opaque).
# =====================================================================
set -e

KDIR="${KITTY_CONFIG_DIRECTORY:-${XDG_CONFIG_HOME:-$HOME/.config}/kitty}"
CONF="$KDIR/kitty.conf"
INC="$KDIR/ellen-transparency.conf"
LINE="include ellen-transparency.conf"
DEFAULT=0.60
MIN=0.2

# demande à tous les kitty ouverts de recharger leur config
reload_kitty() {
  pkill -x -USR1 kitty 2>/dev/null || true
}

# vrai si $1 est un nombre entre MIN et 1
valid_opacity() {
  awk -v v="$1" -v min="$MIN" \
    'BEGIN { exit !(v ~ /^[0-9]*\.?[0-9]+$/ && v + 0 >= min && v + 0 <= 1) }'
}

case "${1:-}" in
  -h|--help)
    sed -n '3,11p' "$0" | sed 's/^# \{0,2\}//'
    exit 0
    ;;

  # Retirer la transparence : bash ellen-transparency.sh --off
  --off)
    rm -f "$INC"
    if [ -f "$CONF" ]; then
      sed -i '/^include ellen-transparency.conf$/d' "$CONF"
    fi
    reload_kitty
    echo "✓ Transparence désactivée."
    exit 0
    ;;
esac

OPACITY="${1:-$DEFAULT}"

if ! valid_opacity "$OPACITY"; then
  echo "Valeur invalide : « $OPACITY ». Entre $MIN et 1.0 (exemple : 0.6)." >&2
  exit 1
fi

mkdir -p "$KDIR"
touch "$CONF"

# une seule sauvegarde, faite la première fois
if [ ! -f "$CONF.bak-ellen" ]; then
  cp "$CONF" "$CONF.bak-ellen"
fi

cat > "$INC" <<CONFIG
background_opacity $OPACITY
dynamic_background_opacity yes
CONFIG

# l'include est placé à la fin pour avoir priorité sur le reste
if ! grep -qxF "$LINE" "$CONF"; then
  # si la dernière ligne n'a pas de retour à la ligne, on en ajoute un
  if [ -s "$CONF" ] && [ -n "$(tail -c1 "$CONF")" ]; then
    echo >> "$CONF"
  fi
  echo "$LINE" >> "$CONF"
fi

reload_kitty
echo "✓ Transparence réglée à $OPACITY."
echo "  Si rien ne change, ferme puis rouvre kitty (nécessaire la première fois)."
