{ user, pkgs, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  # Declared here rather than as Homebrew formulae: homebrew.onActivation.cleanup
  # below is "zap", so anything brew-installed but not listed there is removed on
  # the next activation. nixpkgs packages are unaffected by that sweep.
  environment.systemPackages = with pkgs; [
    nodejs
    tmux
    gh
  ];

  # Let Claude Code (installed via the claude-code@latest cask) run its own
  # `brew upgrade` in the background so it self-updates between rebuilds.
  environment.variables.CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE = "1";

  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "my-monkeys/tap"  # opensuperwhisper; must be listed or cleanup = "zap" untaps it
    ];
    brews = [
      "herdr"
    ];
    casks = [
      "wezterm"
      "claude-code@latest"  # latest/pre-release channel (newest models); NOT the stable "claude-code" cask
      "opensuperwhisper"
      "hammerspoon"
    ];
  };
}
