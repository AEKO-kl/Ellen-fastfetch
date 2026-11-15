# =====================================================================
#  Ellen-fastfetch : fastfetch + images d'Ellen posées par-dessus (kitty)
#  https://github.com/AEKO-kl/Ellen-fastfetch
#
#  Installation : copier ce fichier dans ~/.config/fish/conf.d/
#  Prérequis    : fish, kitty, fastfetch
#  Les fichiers de config et les images sont lus dans ~/.config/fastfetch/
# =====================================================================

# --- seuils de taille de fenêtre (lancer `stty size` pour connaître la tienne) ---
# plein écran si colonnes >= big_cols ET lignes >= big_rows
set -g big_cols 150
set -g big_rows 40
# taille moyenne si colonnes >= mid_cols ET lignes >= mid_rows (sinon : petit)
set -g mid_cols 101
set -g mid_rows 37

# --- images à poser par-dessus (dans l'ordre : la dernière est au-dessus) ---
# Pour en ajouter une : ajoute son préfixe ici + copie un bloc de réglages plus bas
set -g overlay_images ellen sitpose

# Réglages de chaque image, pour chaque taille de fenêtre :
#   x, y = position (en colonnes / lignes depuis le coin haut gauche)
#          un nombre NÉGATIF colle au bord droit / bas : -1 = collé, -3 = marge de 2
#   w, h = taille maximale (l'image garde ses proportions)
#   z    = 1 ou plus : au-dessus du texte ; -1 : derrière le texte

# ---------- Ellen ----------
set -g ellen_img ~/.config/fastfetch/Terminal_Ellen/Ellen2-trim.png
set -g ellen_z 1
# plein écran
set -g ellen_big_x 79
set -g ellen_big_y 1
set -g ellen_big_w 26
set -g ellen_big_h 7
# taille moyenne (37 lignes x 101 colonnes)
set -g ellen_mid_x 85
set -g ellen_mid_y 1
set -g ellen_mid_w 15
set -g ellen_mid_h 8
# petit terminal : coin bas droite de la fenêtre
set -g ellen_small_x 70
set -g ellen_small_y -2
set -g ellen_small_w 26
set -g ellen_small_h 7

# ---------- Ellen sitpose (valeurs de départ, à régler) ----------
set -g sitpose_img ~/.config/fastfetch/Terminal_Ellen/sitpose-trim.png
set -g sitpose_z 2
# plein écran
set -g sitpose_big_x 34
set -g sitpose_big_y 8
set -g sitpose_big_w 14
set -g sitpose_big_h 6
# taille moyenne
set -g sitpose_mid_x 33
set -g sitpose_mid_y 8
set -g sitpose_mid_w 15
set -g sitpose_mid_h 6
# petit terminal
set -g sitpose_small_x 53
set -g sitpose_small_y -3
set -g sitpose_small_w 12
set -g sitpose_small_h 5

# --- fonctions ---

# affiche : "mode lignes colonnes"  (mode = small, mid ou big)
function __img_mode
    set -l sz (string split ' ' (stty size </dev/tty))
    set -l mode small
    if test $sz[2] -ge $big_cols; and test $sz[1] -ge $big_rows
        set mode big
    else if test $sz[2] -ge $mid_cols; and test $sz[1] -ge $mid_rows
        set mode mid
    end
    echo $mode $sz[1] $sz[2]
end

# pose une image : __img_draw ellen
function __img_draw
    set -l p $argv[1]
    set -l info (string split ' ' (__img_mode))
    set -l mode $info[1]
    set -l rows $info[2]
    set -l cols $info[3]

    set -l nx "$p"_"$mode"_x
    set -l ny "$p"_"$mode"_y
    set -l nw "$p"_"$mode"_w
    set -l nh "$p"_"$mode"_h
    set -l ni "$p"_img
    set -l nz "$p"_z

    # image absente : on passe
    test -f $$ni; or return

    set -l x $$nx
    set -l y $$ny
    set -l w $$nw
    set -l h $$nh

    # coordonnée négative : collé au bord droit / bas
    if test $x -lt 0
        set x (math "max(0, $cols - $w + $x + 1)")
    end
    if test $y -lt 0
        set y (math "max(0, $rows - $h + $y + 1)")
    end

    printf '\e7'
    kitten icat --z-index $$nz --place (printf '%sx%s@%sx%s' $w $h $x $y) $$ni
    printf '\e8'
end

# pose toutes les images de la liste
function __img_draw_all
    # les images ne fonctionnent que dans kitty
    test "$TERM" = xterm-kitty; or return
    for p in $overlay_images
        __img_draw $p
    end
end

# redessine tout quand la fenêtre change de taille (Ctrl+F, tiling...)
function __img_redraw --on-signal WINCH
    test -f ~/.config/fastfetch/$fetch_mode.jsonc; or return
    sleep 0.1
    clear
    fastfetch -c ~/.config/fastfetch/$fetch_mode.jsonc
    __img_draw_all
end

# --- lancement ---
if status is-interactive
    # Nom de la config fastfetch à charger (sans .jsonc)
    set -g fetch_mode Ellenconfig

    if test -f ~/.config/fastfetch/$fetch_mode.jsonc
        fastfetch -c ~/.config/fastfetch/$fetch_mode.jsonc
        __img_draw_all
    else
        echo "Config introuvable : ~/.config/fastfetch/$fetch_mode.jsonc"
        fastfetch
    end
end
