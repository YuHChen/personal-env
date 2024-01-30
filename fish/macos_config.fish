alias wp "cd ~/workplace/"

################################################## Command Line Utilities

##################################################
# emacs
##################################################

alias emacs "/usr/local/opt/emacs/bin/emacs"
alias e "emacs -nw"

function clean \
  --description "Recursively clean emacs backup files"

  find . -maxdepth 5 -name ".*~" -type f -delete;
  find . -maxdepth 5 -name "*~" -type f -delete;
end

##################################################
# fish
##################################################

alias refresh-aliases "source ~/.config/fish/config.fish"

function aliases \
  --description "Edit fish configs (abbreviations, aliases, functions)"

  e ~/.config/fish/config.fish;
  refresh-aliases;
  rm -f ~/.config/fish/config.fish~;
end

function fish_prompt \
  --description "Write out the prompt - overwrite fish default"

  set -l user "\e[38;5;141m$USER\e[0m";
  set -l pwd_color_start (set_color $fish_color_cwd);
  set -l pwd_color_end (set_color normal);

  echo -n -s -e $user @ (prompt_hostname) ' ' $pwd_color_start (prompt_pwd) $pwd_color_end '> ';
end

# disable default fish greeting
set fish_greeting

# fix MacOS directory history bug
# see https://github.com/fish-shell/fish-shell/issues/2330
# use `fish_key_reader` and type in `alt-left` and `alt-right`:
# on MacOS, `alt-left` sends `\eb` which maps to `backward-word`
bind \eb prevd-or-backward-word
# on MacOS, `alt-right` sends `\ef` which maps to `forward-word`
bind \ef nextd-or-forward-word

##################################################
# git
##################################################

abbr ga "git add"

abbr gco "git checkout"

abbr gldag "git log --decorate --all --graph"

function wgitstatus \
  --description "Continuously runs `git status` in a repository"

  function _gitstatus
    echo -s "Repo: " (set_color magenta) (basename (pwd)) (set_color normal);
    git status;
  end

  watch _gitstatus;
end

##################################################
# ls
##################################################

alias lls "ls -alrth"

alias llt "lt -a"

alias lt "tree -C -L 2 --filelimit 15"

##################################################
# node
##################################################

# node related CLIs don't work on fish
function add_node_paths \
  --description "Hack to make node related CLIs work on fish" \
  --on-event custom_fish_config_loaded_event

  set -l node_bin_path (bash -c "source ~/.bashrc && echo \$NVM_BIN");
  fish_add_path -g $node_bin_path;
end

##################################################
# tmux
##################################################

alias tmuxconf "e ~/.tmux.conf && tmux source ~/.tmux.conf"

################################################## Custom Functions

function watch \
  --description "Polyfill watch CLI that's missing on MacOS"

  argparse 'i/interval=?!_validate_int --min 1' -- $argv;
  set -l interval 1;
  if set -q _flag_interval
    set interval $_flag_interval;
  end

  while true
    set -l message (echo -s "Every " $interval "s: " (set_color brcyan) $argv (set_color normal));
    set -l date (date "+%a %b %d %X");
    set -l columns (tput cols);
    
    clear;
    # a bit of a hack to right justify the date
    # 1. print date first padded with spaces until string is number of columns long
    # 2. then start printing from the left by using carriage return
    # 3. finally print the message
    printf "%"$columns"s\r%s\n" $date $message;
    echo;
    $argv;
    sleep $interval;
  end
end

################################################## Applications

##################################################
# chrome
##################################################

function chrome \
  --description "Opens URL in Google Chrome" \
  --argument-names url

  if test -z $url
    open -na "Google Chrome";
  else if string match --regex --quiet "https?://" "$url"
    open -na "Google Chrome" "$url";
  else
    open -na "Google Chrome" "https://$url";
  end
end

function chromei \
  --description "Opens URL in Google Chrome in incognito mode" \
  --argument-names url

  if test -z $url
    open -na "Google Chrome";
  else if string match --regex --quiet "https?://" "$url"
    open -na "Google Chrome" --args --incognito "$url";
  else
    open -na "Google Chrome" --args --incognito "https://$url";
  end
end

function google \
  --description "Searches query on Google using Google Chrome" \
  --argument-names query

  if test (count $argv) -gt 1
    chrome "google.com/search?q=$argv";
  else if test -z $query
    chrome google.com;
  else
    chrome "google.com/search?q=$query";
  end
end

function googlei \
  --description "Searches query on Google using Google Chrome in incognito mode" \
  --argument-names query

  if test (count $argv) -gt 1
    chromei "google.com/search?q=$argv";
  else if test -z $query
    chromei google.com;
  else
    chromei "google.com/search?q=$query";
  end
end

################################################## Misc

emit custom_fish_config_loaded_event
