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


set -x UV_PYTHON_PREFERENCE only-system
set -x UV_PYTHON ${pkgs.python312Full}/bin/python

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

''
