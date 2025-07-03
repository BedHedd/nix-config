{ pkgs, ... }:

{
  # Enable the Dconf module
  dconf.enable = true;

  # All of your Guake settings go here
  dconf.settings = {
    # geometry & font toggle
    "org/guake/general" = {
      window-width                   = 100;
      window-height                  = 36;
      window-halignment              = 0;     # 0=Left,1=Center,2=Right
      window-valignment              = 1;     # 0=Top,1=Bottom
      window-horizontal-displacement = 0;
      window-vertical-displacement   = 0;
      use-default-font               = false; # disable “Use system fixed-width font”
    };

    # transparency
    "org/guake/style/background" = {
      transparency = 79;
    };
  };
}
