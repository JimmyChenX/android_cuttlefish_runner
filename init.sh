sudo apt update
#sudo apt install -y libpulse0 libasound2
sudo apt install -y libpulse0 libasound2t64

sudo dpkg -i ./cuttlefish-base_*_*64.deb || sudo apt-get install -f
sudo dpkg -i ./cuttlefish-user_*_*64.deb || sudo apt-get install -f

echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules

sudo udevadm control --reload-rules
sudo udevadm trigger

sudo usermod -aG kvm,cvdnetwork,render $USER