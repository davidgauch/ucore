#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Add mullvad-vpn
mkdir /etc/mullvad-vpn
mkdir /var/opt
ln -s /etc/mullvad-vpn /opt/Mullvad\ VPN
dnf5 config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
dnf5 install -y mullvad-vpn
# Fix broken `/opt/Mullvad VPN/` links
rpm -ql mullvad-vpn | while read -r file; do
    if [[ -L "$file" ]]; then
        ln -sf "$(readlink -f "$file")" "$file"
    elif [[ -f "$file" ]]; then
        sed -i "s|/opt/Mullvad.*VPN/|/etc/mullvad-vpn/|gw /dev/stdout" "$file"
    fi
done
rm /opt/Mullvad\ VPN
rmdir /var/opt

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File
systemctl enable bootc-fetch-apply-updates.timer
systemctl enable cockpit.service
systemctl enable podman-auto-update.timer
systemctl enable zfs-import-scan.service
