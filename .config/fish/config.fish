if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ls='exa -1 --icons --long'
alias update-site='rsync -avh /home/caleb/Nextcloud/Coding/calebleinz.xyz/* root@45.79.78.161:/var/www/html'
alias nv='nvim'
alias hx-update='cd ~/Applications/helix/ && git pull && cargo install --path helix-term'
starship init fish | source
fish_add_path ~/.local/bin

