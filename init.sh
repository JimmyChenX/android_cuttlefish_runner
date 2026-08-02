sudo apt update

ls -l /dev/kvm

#sudo apt install -y libpulse0 libasound2
sudo apt install -y libpulse0 libasound2t64

sudo apt install cuttlefish-base cuttlefish-user cuttlefish-orchestration

echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules

sudo udevadm control --reload-rules
sudo udevadm trigger

sudo usermod -aG kvm,cvdnetwork,render $USER