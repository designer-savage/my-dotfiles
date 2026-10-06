# Убираем приветствие fish
set fish_greeting ""

# pywal
if test -f ~/.cache/wal/sequences
    cat ~/.cache/wal/sequences
end
printf '\033]10;#ffffff\007'

# Цвет вводимого текста — самый светлый из палитры pywal (foreground)
if test -f ~/.cache/wal/colors.sh
    set -l wal_fg (grep -E '^foreground=' ~/.cache/wal/colors.sh | string match -r '[0-9a-fA-F]{6}')
    test -z "$wal_fg"; and set wal_fg ffffff
    set -g fish_color_normal        $wal_fg
    set -g fish_color_command       $wal_fg
    set -g fish_color_keyword       $wal_fg
    set -g fish_color_param         $wal_fg
    set -g fish_color_option        $wal_fg
    set -g fish_color_quote         $wal_fg
    set -g fish_color_redirection   $wal_fg
    set -g fish_color_end           $wal_fg
    set -g fish_color_operator      $wal_fg
    set -g fish_color_escape        $wal_fg
    set -g fish_color_autosuggestion 808080
    set -g fish_color_comment        808080
end

# Startup
clear

# Starship
starship init fish | source

# PATH
fish_add_path $HOME/.local/bin

# ── Aliases ──────────────────────────────────────────────────

alias lsd='eza --icons'
alias pacup='sudo pacman -Rns (pacman -Qdtq)'
alias grep='grep --color=auto'
alias pool='clear && asciiquarium'
alias f='clear && myfetch -i e -f -c 16 -C "  "'
alias bye='sudo shutdown -h now'
alias loop='sudo reboot'
alias h='dbus-launch Hyprland'
alias fonts='fc-list -f "%{family}\n"'
alias tasks='btm'
alias Docs='cd ~/Documents && nvim'
alias Settings='cd ~/.config/hypr && nvim'
alias spot='ncspot'
alias untar='tar -xf'
alias n='nvim'
alias perf='sudo cpupower frequency-set -g performance'
alias psave='sudo cpupower frequency-set -g powersave'
alias celar='clear'
alias pdfopen='xdg-open'
alias clock='tty-clock -c'
alias md2pdf='node ~/.local/lib/node_modules/md-to-pdf/dist/cli.js --launch-options \'{"executablePath":"/usr/bin/google-chrome-stable","args":["--no-sandbox","--disable-setuid-sandbox"]}\''
