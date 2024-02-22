{
  config,
  lib,
  pkgs,
  ...
}: {
  home.stateVersion = "23.11";

  programs.zsh = {
    enable = true;
    enableAutosuggestions = false;
    initExtra = ''
      source ${config.home.homeDirectory}/.secrets-env
    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "fzf" "fd" "ripgrep"];
      theme = "robbyrussell";
    };
  };

  programs.git = {
    enable = true;
    userName = "Artem Markov";
    userEmail = "drownbes@gmail.com";
    difftastic.enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  services.easyeffects.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      import = [
        "${pkgs.alacritty-theme}/oceanic_next.yaml"
      ];
      font = {
        size = 12.0;
        normal = {
          family = "Fira Code";
          style = "Regular";
        };
        bold = {
          family = "Fira Code";
          style = "Bold";
        };
        italic = {
          family = "Fira Code";
          style = "Italic";
        };
      };
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraLuaConfig = lib.fileContents ./init.lua;
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        position = "bottom";
        height = 20;
        modules-left = [
          "sway/mode"
          "sway/workspaces"
        ];

        modules-center = [
          "sway/window"
        ];

        modules-right = [
          "temperature"
          "battery"
          "clock"
          "tray"
        ];
        clock = {
          timezone = "Europe/Tallinn";
        };
      };
    };
  };

  programs.fuzzel = {
    enable = true;
  };
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
    extraConfig = ''
      set $top_dell "Dell Inc. DELL U2723QE GN6P5P3"
      set $bottom_aoc "AOC U34G2G1 0x00000123"
      output $top_dell scale 1.4
      xwayland disable
      exec way-displays > /tmp/way-displays.$${XDG_VTNR}.$${USER}.log 2>&1
    '';
    config = {
      terminal = "alacritty";
      menu = "fuzzel -b 000000ff -f SourceCodePro:size=12 -i Arc -w 40 -l 25";
      fonts = {
        names = ["Fira Code"];
        size = 12.0;
      };
      bars = [
        {
          command = "waybar";
        }
      ];
    };
  };

  programs.irssi = {
    enable = true;
    networks = {
      liberachat = {
        nick = "drownbes";
        server = {
          address = "irc.libera.chat";
          port = 6697;
          autoConnect = true;
        };
        channels = {
          nixos.autoJoin = true;
        };
      };
    };
  };
}
