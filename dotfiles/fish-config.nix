{ }:
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


''
