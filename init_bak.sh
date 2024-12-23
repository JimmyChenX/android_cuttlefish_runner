sudo apt update
sudo apt install -y git devscripts equivs config-package-dev debhelper-compat golang curl
git clone https://github.com/google/android-cuttlefish
cd android-cuttlefish
tools/buildutils/build_packages.sh
sudo dpkg -i ./cuttlefish-base_*_*64.deb || sudo apt-get install -f sudo dpkg -i ./cuttlefish-user_*_*64.deb || sudo apt-get install -f sudo usermod -aG kvm,cvdnetwork,render $USER
#sudo reboot
