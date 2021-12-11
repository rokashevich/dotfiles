{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];
	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Moscow";
  networking.hostName = "d";
  
  networking.networkmanager.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  hardware.opengl.enable = true;
	hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  
  users.users.r = {
     isNormalUser = true;
     extraGroups = [ "wheel" "video" "networkmanager" ]; 
  };

  nixpkgs.config.allowUnfree = true;

  # Auto login and start gui session
	services.getty.autologinUser = "r";
 	environment.etc."bashrc.local".text = ''
   	if [[ -z $DISPLAY && $(tty) == /dev/tty1 && $XDG_SESSION_TYPE == tty ]]; then
			XDG_SESSION_TYPE=wayland exec dbus-run-session gnome-session 
			#gnome-shell --wayland
   	fi
  '';
  
 	environment.variables.PATH = [ "$HOME/.local/bin" ];

  # Shorter prompt without a new line   
  programs.bash.promptInit = ''PROMPT_COLOR="1;31m";((UID))&&PROMPT_COLOR="1;32m";PS1="\[\033[$PROMPT_COLOR\]\u@\h:\w\\$\[\033[0m\] "'';

  environment.systemPackages = with pkgs; [
	curl wget lsof sysstat
	unzip
	jq
	git
	usbutils cifs-utils
	firefox qbittorrent 
	mc tmux
	youtube-dl
 	#gnome.gnome-session gnome.gnome-terminal gnome.nautilus gnome.gedit gnome.gnome-tweaks gnome.gnome-calculator gnome.adwaita-icon-theme gnome.gnome-control-center gnome.gnome-power-manager gnome.eog gnome.totem gnome.gnome-disk-utility
 	gnome.gnome-session gnome.gnome-shell gnome.gnome-terminal gnome.nautilus gnome.gedit gnome.gnome-tweaks gnome.gnome-calculator gnome.adwaita-icon-theme gnome.gnome-control-center gnome.gnome-power-manager gnome.totem gnome.gnome-disk-utility gnome.gnome-screenshot
	evince
  gthumb
  glib
  #dconf
  #gnome.mutter gnome.gnome-keyring gnome.gnome-keyring gnome.gvfs gnome.gnome-session gnome.gnome-desktop 

	(
	vim_configurable.customize{
      		name = "vi";
		vimrcConfig.customRC = ''
		syntax enable
		set nobackup
		set autochdir
		set number
		set tabstop=2
		au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
		'';
		vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
        		start = [
			];
		};
	})
  ];

  fonts.fonts = with pkgs; [
    ubuntu_font_family
  ];
	#security.polkit.enable = true; # ???
	services.gnome.gnome-settings-daemon.enable = true; # ???
	services.gnome.gnome-keyring.enable = true;
	services.upower.enable = true;
 	services.udev.packages = with pkgs; [ 
 		pkgs.android-udev-rules
    #pkgs.libmtp.bin # ???
  ];
	services.gvfs.enable = true;
	services.dbus.packages = with pkgs; [ 
		dconf # Required for saving changes in Settings! 
		gnome.gvfs
	];
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC="performance";
      CPU_SCALING_GOVERNOR_ON_BAT="powersave";
      START_CHARGE_THRESH_BAT1=75;
      STOP_CHARGE_THRESH_BAT1=80;
    };
  };
  system.stateVersion = "21.11";
}

