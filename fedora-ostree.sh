# Functions for Fedora

#### LIST OF FUNCTIONS

### Terra repos
# f_terra
### RPM-fusion
# f_rpmfusion
### Fedora auto updates
# f_updates
### Flatpak auto updates
# f_flatpak
### First boot setup
# f_firstboot
### Multimedia
# f_multimedia
### Firefox
# f_firefox
### Fonts
# f_fonts
### CachyOS Kernel
# f_cachy
### Mesa-git Mesa Freeworld
# f_mesa-freeworld
### Mesa-git Mesa Freeworld
# f_mesa-git
### Gaming
# f_gaming
### Utils
# f_utils
### GNOME
# f_gnome
### Tailscale
# f_tailscale
### Distrobox
# f_distrobox
# f_libvirt

#===========================================================#

### Terra repos
function f_terra(){
	echo "Enabling Terra"
	#curl -o /etc/yum.repos.d/terra.repo "https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo"
	dnf config-manager addrepo --from-repofile=https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo
	dnf install -y terra-release
}

### RPM-fusion
function f_rpmfusion(){
	echo "Enabling RPM fusion"
	dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	dnf install -y rpmfusion-free-release rpmfusion-nonfree-release
}

### Fedora auto updates
function f_updates(){
	echo "Enabling auto updates"
 	#sudo sed -i 's/#AutomaticUpdatePolicy=none/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
	sed -i 's/#AutomaticUpdatePolicy=none/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
	systemctl enable rpm-ostreed-automatic.timer
}

### Flatpak auto updates
function f_flatpak(){
	echo -e "[Unit]\nDescription=Update Flatpaks\n[Service]\nType=oneshot\nExecStart=/usr/bin/flatpak uninstall --unused -y --noninteractive ; /usr/bin/flatpak update -y --noninteractive ; /usr/bin/flatpak repair\n[Install]\nWantedBy=default.target\n" | tee /etc/systemd/system/flatpak-update.service
	systemctl enable flatpak-update.service
	echo -e "[Unit]\nDescription=Update Flatpaks\n[Timer]\nOnCalendar=*:0/4\nPersistent=true\n[Install]\nWantedBy=timers.target\n" | tee /etc/systemd/system/flatpak-update.timer
	systemctl enable flatpak-update.timer
}

### First boot setup
function f_firstboot(){
	echo -e "[Unit]\nDescription=First Boot Setup\nAfter=network.target\nConditionPathExists=!/var/home/pc/.config/gnome-initial-setup-done\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/flatpak uninstall --all -y --noninteractive\nExecStart=/usr/bin/flatpak remote-delete --force fedora\nExecStart=/usr/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo\nExecStart=/usr/bin/bash -c 'curl -sSL ${FLATPAK_PACKAGE_LIST_URL} | xargs -r flatpak install -y --noninteractive'\n\n[Install]\nWantedBy=multi-user.target" | tee /etc/systemd/system/first-boot.service
	systemctl enable first-boot.service
}

#cat /usr/lib/systemd/system/flatpak-add-fedora-repos.service
#[Unit]
#Description=Add Fedora flatpak repositories
#ConditionPathExists=!/var/lib/flatpak/.fedora-initialized
#Before=flatpak-system-helper.service
#
#[Service]
#Type=oneshot
#RemainAfterExit=yes
#ExecStart=/usr/bin/flatpak remote-add --system --if-not-exists --title "Fedora Flatpaks" fedora oci+https://registry.fedoraproject.org
#ExecStart=/usr/bin/flatpak remote-add --system --if-not-exists --disable --title "Fedora Flatpaks (testing)" fedora-testing oci+https://registry.fedoraproject.org#testing
#ExecStartPost=/usr/bin/touch /var/lib/flatpak/.fedora-initialized
#
#[Install]
#WantedBy=multi-user.target
#


### Multimedia
function f_multimedia(){
	#https://docs.fedoraproject.org/en-US/quick-docs/installing-plugins-for-playing-movies-and-music/
	dnf group install -y multimedia
	dnf remove -y \
	ffmpeg-free \
	libavcodec-free \
	libavdevice-free \
	libavfilter-free \
	libavformat-free \
	libavutil-free \
	libpostproc-free \
	libswresample-free \
	libswscale-free \
	--install=ffmpeg \
	--install=gstreamer1-plugin-libav \
	--install=gstreamer1-plugins-bad-free-extras \
	--install=gstreamer1-plugins-bad-freeworld \
	--install=gstreamer1-plugins-ugly \
	--install=gstreamer1-vaapi
}

### Firefox
function f_firefox(){
	dnf remove -y firefox firefox-langpacks
}

### Fonts
function f_fonts(){
	install_packages=(
	"ibm-plex-fonts-all"
	"rsms-inter-fonts"
	"levien-inconsolata-fonts"
	)
	dnf install -y ${install_packages[@]}
}

### CachyOS Kernel
function f_cachy(){
	setsebool -P domain_kernel_load_modules on
	dnf remove -y kernel*
	dnf copr enable -y bieszczaders/kernel-cachyos
	dnf install -y kernel-cachyos kernel-cachyos-devel-matched
	sudo dnf copr enable bieszczaders/kernel-cachyos-addons
	#sudo dnf install libcap-ng libcap-ng-devel procps-ng procps-ng-devel
	sudo dnf install uksmd
	sudo systemctl enable --now uksmd.service
}

### Mesa-git Mesa Freeworld
function f_mesa-freeworld(){
	#dnf copr enable -y xxmitsu/mesa-git
	dnf install -y mesa-va-drivers-freeworld
	dnf install -y mesa-vdpau-drivers-freeworld
}

### Mesa-git Mesa Freeworld
function f_mesa-git(){
	dnf copr enable -y xxmitsu/mesa-git
	dnf upgrade -y
}

### Gaming
function f_gaming(){
	# RPM Fusion
	#dnf install -y steam.i686 steam.x86_64 steam-devices.i686 steam-devices.x86_64
	dnf install -y steam steam-devices
	# Terra
	dnf install -y umu-launcher
	# COPR
	dnf copr enable -y gui1ty/bottles
	dnf install -y bottles
	dnf copr enable -y atim/heroic-games-launcher
	dnf install -y heroic-games-launcher-bin
	dnf copr enable -y g3tchoo/prismlauncher
	dnf install -y prismlauncher
	#dnf copr enable -y faugus/faugus-launcher
	#dnf install -y faugus-launcher
	# Fedora
	#dnf install -y goverlay mangohud.x86_64 mangohud.i686 vkBasalt.x86_64 vkBasalt.i686 gamemode.x86_64 gamemode.i686
	dnf install -y goverlay mangohud vkBasalt gamemode
	# Local RPM - Heroic
	#wget -O heroic-latest.rpm $(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | jq -r '.assets[] | select(.name | contains ("rpm")) | .browser_download_url')
	#curl -L -o /tmp/heroic-latest.rpm $(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | jq -r '.assets[] | select(.name | contains ("rpm")) | .browser_download_url')
	#dnf install -y /tmp/heroic-latest.rpm
	#rpm-ostree install heroic-latest.rpm
	#rpm -i heroic-latest.rpm
}

### Utils
function f_utils(){
	dnf install -y micro python-pip pipx
 	dnf copr enable -y jackgreiner/piper-git
	dnf install -y piper
	systemctl enable ratbagd.service
	dnf install -y input-remapper
	systemctl enable input-remapper
}

### GNOME
function f_gnome(){
	remove_packages=(
	"gnome-classic-session"
	"gnome-shell-extension-window-list"
	"gnome-shell-extension-background-logo"
	"gnome-shell-extension-launch-new-instance"
	"gnome-shell-extension-apps-menu"
	"gnome-shell-extension-places-menu"
	"gnome-tour"
	"yelp"
	"yelp-libs"
	"yelp-xsl"
	)
 
	dnf remove -y gnome-shell-extension*
	dnf remove -y gnome-tour
	dnf remove -y yelp*
	dnf remove -y gnome-software*
	dnf remove -y virtualbox-guest-additions
	#dnf remove -y ${remove_packages[@]}

	install_packages=(
	"adw-gtk3-theme"
	"ffmpegthumbnailer"
	"gnome-shell-extension-caffeine"
	"gnome-shell-extension-light-style"
	)
	dnf install -y ${install_packages[@]}

	git clone https://github.com/mukul29/legacy-theme-auto-switcher-gnome-extension.git /usr/share/gnome-shell/extensions/legacyschemeautoswitcher@joshimukul29.gmail.com
	#git clone https://github.com/neuromorph/openbar.git /usr/share/gnome-shell/extensions/openbar@neuromorph
	#git clone https://github.com/joaophi/tailscale-gnome-qs.git /tmp && mv /tmp/tailscale@joaophi.github.com /usr/share/gnome-shell/extensions/
}

### Tailscale
function f_tailscale(){
	#curl -o /etc/yum.repos.d/_tailscale.repo "https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
	#dnf install -y tailscale
	#systemctl enable tailscaled
	dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
	dnf install -y tailscale
	systemctl enable tailscaled
	rpm -qa | sort | grep tailscale
	git clone https://github.com/joaophi/tailscale-gnome-qs.git /tmp && mv /tmp/tailscale@joaophi.github.com /usr/share/gnome-shell/extensions/
}

### Distrobox
function f_distrobox(){
	dnf remove -y toolbox
	dnf install -y distrobox
	echo -e "[Unit]\nDescription=distrobox-upgrade Automatic Update\n\n[Service]\nType=simple\nExecStart=distrobox-upgrade --all\nStandardOutput=null\n" | tee /etc/systemd/system/distrobox-upgrade.service
	echo -e "[Unit]\nDescription=distrobox-upgrade Automatic Update Trigger\n\n[Timer]\nOnBootSec=1h\nOnUnitInactiveSec=1d\n\n[Install]\nWantedBy=timers.target\n" | tee /etc/systemd/system/distrobox-upgrade.timer
	systemctl enable distrobox-upgrade.timer
}

### libvirt
function f_libvirt(){
	# https://docs.fedoraproject.org/en-US/quick-docs/virtualization-getting-started/
	# dnf install -y @virtualization # virt-viewer
	dnf install -y virt-install virt-manager libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm
	systemctl enable libvirtd
}

#===========================================================#
