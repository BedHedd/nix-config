# modules/universal.nix
{ lib, ... }:

{
  # put *cross-platform* defaults here
  time.timeZone      = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # (add other options that every OS should see)
}
