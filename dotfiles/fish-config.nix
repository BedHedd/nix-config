{ pkgs }:
''
# Custom Fish configuration extras
set -g fish_key_bindings fish_default_key_bindings
bind \cc kill-whole-line repaint
bind \cd forward-char

# Add any additional commands here, like initializing zoxide:
# eval (zoxide init fish)

# zoxide init --cmd cd fish | source

function fish_user_key_bindings
  if command -s fzf-share >/dev/null
    source (fzf-share)/key-bindings.fish
  end

  fzf_key_bindings
end

set -gx EDITOR nvim
set -gx VISUAL nvim

function source --wraps=source
    set -l file $argv[1]
    if test -n "$file"
        if string match -q "*.venv/bin/activate" "$file"
            set -l fish_file "$file.fish"
            if test -f "$fish_file"
                echo "activating environment: $fish_file"
                builtin source "$fish_file"
                return $status
            else
                echo "No fish activation script found!" 1>&2
                return 1
            end
        end
    end
    builtin source $argv
end

function dev_mode
    # Define a new fish_prompt for developer mode
    function fish_prompt
        # Set prompt colors
        set color_green (set_color green)
        set color_cyan (set_color cyan)
        set color_reset (set_color normal)

        # Set custom username and hostname
        set custom_user "bedhedd"
        set custom_host "codium"

        # Get the current working directory
        set full_path (pwd)

        # Process the path to abbreviate each component to its first letter
        # except for the last component, which is shown in full
        set -l abbreviated_path
        set -l path_components (string split '/' $full_path)
        for i in (seq 2 (math (count $path_components) - 1))
            set -l component (string sub -l 1 $path_components[$i])
            set abbreviated_path "$abbreviated_path/$component"
        end
        set abbreviated_path "$abbreviated_path/$path_components[-1]"

        # Construct the custom prompt with green username and hostname, and cyan path
        echo -n "$color_green$custom_user$color_reset@$custom_host $color_cyan$abbreviated_path$color_reset > "
    end

    echo "Developer mode activated."
    clear  # Clear the terminal screen
end

# Auto-detect Codium and activate dev_mode
if string match -rq 'codium' (ps -o comm= -p (ps -o ppid= -p $fish_pid | string trim))
    dev_mode
end
''
