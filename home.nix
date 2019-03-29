{ config, pkgs, lib, ... }:

let 
  pulseaudio = pkgs.pulseaudioFull;

  # Spotify is terrible on hidpi screens (retina, 4k); this small wrapper 
  # passes a command-line flag to force better scaling.
  spotify-4k = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify \
        --add-flags "--force-device-scale-factor=1.75"
    '';
  };

in

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages which ought to be available for this user
  home.packages = with pkgs; [
    # system
    feh playerctl
    
    # i3 
    dmenu

    # command line
    htop

    # applications
    firefox spotify-4k slack
  ];

  home.keyboard = {
    layout = "us, us";
    variant = "dvorak, ";
    options = [ 
      "grp:alt_shift_toggle" # toggle variants with alt+shift 
      "caps:escape" # remap caps to escape
    ];
  };

  programs.git = {
    enable = true;
    userName = "Thomas Honeyman";
    userEmail = "admin@thomashoneyman.com";
    extraConfig = {
      core.editor = "vim";
      github.username = "thomashoneyman";
    };
    aliases = {
      l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
    };
  };

  programs.vim = {
    enable = true;

    # to see available plugins:
    # nix-env -f '<nixpkgs>' -qaP -A vimPlugins
    #
    # 'sensible' included by default
    plugins = [
      # Writing
      "goyo" # distraction-free writing; toggle with :Goyo
      "vim-pencil" # better word-wrapping, markdown, etc.
      "vim-wordy" # catch usage problems in writing
      "limelight-vim" # highlight only current paragraph
    ];

    extraConfig = ''
      " set up writing environment when goyo starts
      function! s:goyo_enter()
        set noshowmode
        set noshowcmd
        Limelight  " start limelight
        SoftPencil " start pencil with soft wrap
      endfunction

      " clear writing environment when goyo exits
      function! s:goyo_leave()
        set showmode
        set showcmd
        Limelight! " quit limelight
        NoPencil   " quit pencil
      endfunction

      autocmd! User GoyoEnter nested call <SID>goyo_enter()
      autocmd! User GoyoLeave nested call <SID>goyo_leave()

      " set limelight colors
      let g:limelight_conceal_ctermfg = 'DarkGray'
    '';
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
    };
    shellOptions = [
      # defaults
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"

      # save multi-line commands as single entries
      "cmdhist"
    ];
    initExtra = ''
      # case-insensitive file completion
      bind "set-completion-ignore-case on"
    '';
  };

  # irc
  programs.irssi = {
    enable = false;
    networks = {
      freenode = {
        nick = "thomashoneyman";
        server = {
          address = "chat.freenode.net";
          autoConnect = true;
        };
        channels = {
          nixos.autoJoin = true;
        };
      };
    };
  };

  # enable the Nord theme
  programs.termite = {
    enable = true;
    font = "Overpass Mono";

    # https://github.com/arcticicestudio/nord-termite/
    colorsExtra = ''
      cursor = #d8dee9
      cursor_foreground = #2e3440
      foreground = #d8dee9
      foreground_bold = #d8dee9
      background = #2e3440
      highlight = #4c566a
      color0  = #3b4252
      color1  = #bf616a
      color2  = #a3be8c
      color3  = #ebcb8b
      color4  = #81a1c1
      color5  = #b48ead
      color6  = #88c0d0
      color7  = #e5e9f0
      color8  = #4c566a
      color9  = #bf616a
      color10 = #a3be8c
      color11 = #ebcb8b
      color12 = #81a1c1
      color13 = #b48ead
      color14 = #8fbcbb
      color15 = #eceff4
    '';
  };

  programs.htop = {
    enable = true;
  };

  # ssh
  programs.ssh.enable = true;

  # few extensions are in nixpkgs as of yet. good pet project?
  programs.vscode = {
    enable = true;

    # overrides manually-installed extensions. almost none in nixpkgs right now.
    extensions = [ ];

    # vscode settings.json is made read-only and controlled via this section; editing settings
    # in the ui will reveal what to copy over here.
    userSettings = {
      # editor settings
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "editor.fontSize" = 14;
      "editor.lineHeight" = 24;
      "editor.fontFamily" = "Hasklig, Overpass Mono, monospace";
      "editor.fontLigatures" = true;
      "editor.tabSize" = 2;
      "editor.rulers" = [80 100];

      # languages
      "purescript.addNpmPath" = true;

      # theme
      "workbench.colorTheme" = "Nord";
      "editor.tokenColorCustomizations" = {
        "[Nord]" = {
          "textMateRules" = [ 
            {
              "scope" = [ "entity.name.type.purescript" ];
              "settings" = {
                "foreground" = "#88C0D0";
              };
            }
          ];
        };
      };

      # misc
      "workbench.activityBar.visible" = false;
      "breadcrumbs.enabled" = true;
      "git.autofetch" = true;
      "window.zoomLevel" = 0;
      "css.validate" = false;
      "scss.validate" = false;
      "less.validate" = false;
      "files.associations" = {
        "*.css" = "scss";
        "*.js" = "javascript";
      };
    };
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    extraConfig = 
    let
      white = "#ECEFF4";
      gray = "#65737E";
      black = "#232423";
      blue = "#88C0D0";
      yellow = "#EBCB8B";
      orange = "#D08770";
      red = "#BF616A";
      green = "#A3BE8C";
      magenta = "#B48EAD";
      background = "#802E3440";

      overpass = "Overpass Mono:pixelsize=9;2";
      monofur = "Monofur Nerd Font:pixelsize=9;2";
    in
    # inspired by /ossix/dotfiles/dark-forest
    ''
    [global/wm]
    margin-top = 0
    margin-bottom = 0

    # Settings
    [settings]
    screenchange-reload = true

    #
    # Bars
    #

    [bar/top]
    dpi = 192
    radius = 0.0
    fixed-center = true
    bottom = false
    height = 40
    padding-left = 3
    padding-right = 4
    background = ${background}
    foreground = ${white}
    module-margin = 1
    underline-size = 1
    border-bottom-size = 2
    border-color = ${gray}
    separator = " "

    font-0 = "TerminessTTF Nerd Font:size=9;2"
    font-1 = Font Awesome 5 Free:style=Regular:pixelsize=9;2
    font-2 = Font Awesome 5 Free:style=Solid:pixelsize=9;2
    font-3 = Font Awesome 5 Brands:pixelsize=9;2
    font-4 = "TerminessTTF Nerd Font:style=Bold:size=9;2"
    font-5 = FontAwesome:size=8;2
    font-6 = fontawesome:size=9;2

    enable-ipc = true

    modules-right = cpu memory battery volume
    modules-center = date
    modules-left = i3 xwindow

    #
    # Modules
    #

    [module/cpu]
    type = internal/cpu
    interval = 0.5

    format-prefix = 
    format = <label> <ramp-coreload>

    label = %{A1:termite --exec=htop & disown:}%percentage:3%%%{A}

    ramp-coreload-0 = ▁
    ramp-coreload-1 = ▂
    ramp-coreload-2 = ▃
    ramp-coreload-3 = ▄
    ramp-coreload-4 = ▅
    ramp-coreload-5 = ▆
    ramp-coreload-6 = ▇
    ramp-coreload-7 = █
    ramp-coreload-0-foreground = ${gray}
    ramp-coreload-1-foreground = ${green}
    ramp-coreload-2-foreground = ${green}
    ramp-coreload-3-foreground = ${yellow}
    ramp-coreload-4-foreground = ${yellow}
    ramp-coreload-5-foreground = ${orange}
    ramp-coreload-6-foreground = ${orange}
    ramp-coreload-7-foreground = ${red}


    [module/memory]
    type = internal/memory
    interval = 0.2
    format-prefix = 
    format = <label> <ramp-used>
    label = %{A1:termite --exec=htop & disown:}%percentage_used:3%%%{A}

    ramp-used-0 = ▁
    ramp-used-1 = ▂
    ramp-used-2 = ▃
    ramp-used-3 = ▄
    ramp-used-4 = ▅
    ramp-used-5 = ▆
    ramp-used-6 = ▇
    ramp-used-7 = █
    ramp-used-0-foreground = ${gray}
    ramp-used-1-foreground = ${green}
    ramp-used-2-foreground = ${green}
    ramp-used-3-foreground = ${yellow}
    ramp-used-4-foreground = ${yellow}
    ramp-used-5-foreground = ${orange}
    ramp-used-6-foreground = ${orange}
    ramp-used-7-foreground = ${red}


    [module/battery]
    type = internal/battery
    battery = BAT0
    adapter = ADP1
    full-at = 100
    interval = 1

    format-charging-prefix = 
    format-charging = <label-charging>
    label-charging = %percentage:3%%

    format-discharging = <ramp-capacity><label-discharging>
    label-discharging = %percentage:3%%

    format-full-prefix = 
    format-full = <label-full>
    label-full = %percentage:3%%

    ramp-capacity-0 = 
    ramp-capacity-0-font = 7
    ramp-capacity-1 = 
    ramp-capacity-1-font = 7
    ramp-capacity-2 = 
    ramp-capacity-2-font = 7
    ramp-capacity-3 = 
    ramp-capacity-3-font = 7
    ramp-capacity-4 = 
    ramp-capacity-4-font = 7
    ramp-capacity-0-foreground = ${red}
    ramp-capacity-1-foreground = ${orange}
    ramp-capacity-2-foreground = ${yellow}
    ramp-capacity-foreground = ${white}


    [module/volume]
    type = internal/pulseaudio
    format-volume = <ramp-volume><label-volume>
    label-volume = %percentage:3%%
    label-volume-foreground = ${white}

    format-muted-prefix = 
    format-muted-foreground = ${gray}
    label-muted = %percentage:3%%

    ramp-volume-0 = 
    ramp-volume-0-foreground = ${gray}
    ramp-volume-1 = 
    ramp-volume-1-foreground = ${yellow}
    ramp-volume-2 = 
    ramp-volume-2-foreground = ${orange}
    ramp-volume-3 = 
    ramp-volume-3-foreground = ${red}


    [module/date]
    type = internal/date
    date-alt = "%a - %m/%d"
    date = "%{T5}%I:%M%{T-}"
    interval = 1
    format-padding = 1
    format-background = ${gray}


    [module/i3]
    type = internal/i3
    format = <label-state>
    index-sort = true
    wrapping-scroll = false
    format-padding-right = 1

    label-focused = %name%
    label-focused-background = ${gray}
    label-focused-foreground = ${white}
    label-focused-overline  = ${gray}
    label-focused-padding = 2
    label-focused-font = 5

    label-unfocused = %name%
    label-unfocused-padding = 1
    label-unfocused-foreground = ${gray}
    label-unfocused-overline = ${background}

    label-occupied = %name%
    label-occupied-padding = 1

    label-urgent = 
    label-urgent-background = ${red}
    label-urgent-overline  = ${red}
    label-urgent-padding = 2

    label-empty = %name%
    label-empty-foreground = ${gray}
    label-empty-overline = ${background}
    label-empty-padding = 1

    label-visible = %name%
    label-visible-overline = ${background}
    label-visible-padding = 2


    [module/xwindow]
    type = internal/xwindow
    label =   %title:0:40:...%
    label-empty = root-window
    label-empty-foreground = ${yellow}
    label-background = ${gray}
    label-padding = 1
    click-left = skippy-xd
    click-right = skippy-xd
    '';

    # necessary to include i3 path to start correctly
    script = ''
      PATH=$PATH:${pkgs.i3}/bin polybar top &
    '';
  };

  xresources = {
    extraConfig =
      builtins.readFile (
        # nix-prefetch-git
        pkgs.fetchFromGitHub {
          owner = "arcticicestudio";
          repo = "nord-xresources";
          rev = "5a409ca2b4070d08e764a878ddccd7e1584f0096";
          sha256 = "1b775ilsxxkrvh4z8f978f26sdrih7g8w2pb86zfww8pnaaz403m";
        } + "/src/nord"
      );
  };

  xsession = {
    enable = true;

    # i3 configuration
    windowManager.i3 = let modifier = "Mod4"; in {
      enable = true;

      config = { 
        modifier = "${modifier}";

        bars = [ ];

        keybindings = 
        lib.mkOptionDefault {
          "${modifier}+Return" = "exec termite";
          "${modifier}+q" = "kill";
          "${modifier}+f" = "fullscreen toggle";

          "XF86AudioRaiseVolume" = "exec ${pulseaudio}/bin/pactl set-sink-volume 0 +5%";
          "XF86AudioLowerVolume" = "exec ${pulseaudio}/bin/pactl set-sink-volume 0 -5%";
          "XF86AudioMute" = "exec ${pulseaudio}/bin/pactl set-sink-mute 0 toggle";

	  "XF86MonBrightnessUp" = "exec light -A 10%";
	  "XF86MonBrightnessDown" = "exec light -U 10%";

	  "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
	  "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
	  "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        };

	# ensure these commands are run when i3 is restarted
	startup = [
	  { command = "sh ~/.fehbg"; always = true; notification = false; }
	  { command = "systemctl --user restart polybar"; always = true; notification = false; }
	];

      };

    extraConfig = ''
      default_border pixel 1 
      hide_edge_borders smart
    '';
    };

  };

  # autorandr enables switching xrandr profiles when display devices change or the screen sleeps
  # this config enables either only the laptop screen, or, if connected to a monitor via the
  # DisplayPort output, disables the laptop screen and displays only the monitor.
  programs.autorandr = {
    enable = true;
    hooks = {
      postswitch = {
        "notify-i3" = "''${pkgs.i3}/bin/i3-msg restart"; # make sure to restart i3 after reloading
      };
    };
    profiles = {
      "home-4k" = {
        fingerprint = {
          eDP = "00ffffffffffff0006102fa00000000004190104a5211578026fb1a7554c9e250c505400000001010101010101010101010101010101ef8340a0b0083470302036004bcf1000001a000000fc00436f6c6f72204c43440a20202000000010000000000000000000000000000000000010000000000000000000000000000000cf";
          DisplayPort-0 = "00ffffffffffff00220e363500000000161c0104b53c22783eee95a3544c99260f5054a10800d1c0a9c081c0d100b3009500810081804dd000a0f0703e803020350055502100001a000000fd001d3c1c873c010a202020202020000000fc004850205a32370a202020202020000000ff00434e34383232303246470a2020019902031ef15161100403021f1312115f051407061615012309070783010000a36600a0f0701f803020350055502100001a023a801871382d40582c450055502100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b9";
        };
        config = {
          eDP.enable = false;
          DisplayPort-0 = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "3840x2160";
            rate = "60.00";
          };
        };
      };
      "mobile" = {
        fingerprint = {
          eDP = "00ffffffffffff0006102fa00000000004190104a5211578026fb1a7554c9e250c505400000001010101010101010101010101010101ef8340a0b0083470302036004bcf1000001a000000fc00436f6c6f72204c43440a20202000000010000000000000000000000000000000000010000000000000000000000000000000cf";
        };
        config = {
          eDP = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2880x1800";
            rate = "60.00";
          };
        };
      };
    };
  };
}