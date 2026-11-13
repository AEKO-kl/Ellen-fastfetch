# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != "linux"
        alias ls 'eza --icons=auto'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
end

        #AUTO launch fastfetch

       # ---- réglages de l'image Ellen (à modifier) ----

set -g ellen_img ~/.config/fastfetch/Terminal_Ellen/Ellen2-trim.png
set -g ellen_w 26          # largeur max, en colonnes
set -g ellen_h 7           # hauteur max, en lignes
set -g ellen_z 1           # 1 = au-dessus du texte, -1 = derrière

# grand terminal (plein écran) : position fixe
set -g ellen_big_x 71
set -g ellen_big_y 1
# on est en "grand terminal" si la fenêtre fait au moins cette taille :
set -g ellen_big_cols 150
set -g ellen_big_rows 40

# taille moyenne (37 lignes x 101 colonnes) : plus haut, sur le coin du cadre
set -g ellen_mid_cols 101
set -g ellen_mid_rows 37
set -g ellen_mid_x 72
set -g ellen_mid_y 24
set -g ellen_mid_w 17
set -g ellen_mid_h 4

# petit terminal : coin bas droite, avec une marge (colonnes / lignes)
set -g ellen_margin_x 0
set -g ellen_margin_y 0


function __ellen_draw
    # taille réelle de la fenêtre
        set -l sz (string split ' ' (stty size </dev/tty))
    set -l rows $sz[1]
    set -l cols $sz[2]

    set -l x
    set -l y
    if test $cols -ge $ellen_big_cols -a $rows -ge $ellen_big_rows
        set x $ellen_big_x
        set y $ellen_big_y
    else
        set x (math "max(0, $cols - $ellen_w - $ellen_margin_x)")
        set y (math "max(0, $rows - $ellen_h - $ellen_margin_y)")
    end

    printf '\e7'
    kitten icat --z-index $ellen_z --place (printf '%sx%s@%sx%s' $ellen_w $ellen_h $x $y) $ellen_img
    printf '\e8'
end



# redessine tout quand la fenêtre change de taille (Ctrl+F, tiling...)
function __ellen_redraw --on-signal WINCH
    test -f ~/.config/fastfetch/$fetch_mode.jsonc; or return
    test "$fetch_mode" = Ellenconfig; or return
    sleep 0.1
    clear
    fastfetch -c ~/.config/fastfetch/$fetch_mode.jsonc
    __ellen_draw
end





if status is-interactive
    # Choix de l'affichage : images, ascii, ou le nom d'une config (ex : Ellenconfig)
    set -g fetch_mode Ellenconfig

    switch $fetch_mode
        case ascii
            fastfetch -c ~/.config/fastfetch/config-ascii.jsonc

        case images
            set -g fetch_logo (find ~/.config/fastfetch/logos -type f | shuf -n1)

            # lance fastfetch avec la taille propre à chaque image
            function __fetch_run
                switch (basename $fetch_logo)
                    case Rias.png
                        set w 17
                        set h 8
                    case Akeno.png
                        set w 20
                        set h 10
                    case '*'
                        set w 17
                        set h 8
                end
                fastfetch --logo-type kitty-direct --logo $fetch_logo --logo-width $w --logo-height $h
            end

            # redessine quand la fenêtre change de taille
            function __fetch_redraw --on-signal WINCH
                sleep 0.1
                clear
                __fetch_run
            end

            __fetch_run

        case '*'
            if test -f ~/.config/fastfetch/$fetch_mode.jsonc
                fastfetch -c ~/.config/fastfetch/$fetch_mode.jsonc
                __ellen_draw
            else
                echo "Config introuvable : ~/.config/fastfetch/$fetch_mode.jsonc"
                fastfetch
            end
    end
end
