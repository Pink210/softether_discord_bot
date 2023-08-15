#!/usr/bin/env bash
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear

# Check for Update script
if [ -d "/bot/SoftBot" ]; then
  echo "SoftBot is already installed. The script is attempting to create a backup."
  echo "USE 'Ctrl + C' to cancel it."
  sudo systemctl stop SoftBot
  sleep 2
  sudo mkdir /bot/backup
  sleep 2
  sudo cp -f /bot/softether/msg.py /bot/backup/msg.py.bak
  sleep 2
  sudo cp -f /bot/softether/setup.py /bot/backup/setup.py.bak
  sleep 2
  sudo systemctl disable SoftBot
fi

# Start from here
# Perform apt update
sudo apt-get update -y && sudo apt-get -o Dpkg::Options::="--force-confold" -y upgrade -y && sudo apt-get autoremove -y 
sleep 2

# install necessary pip
pip install discord.py pandas json time discord.ext

# Download SoftBot
git clone https://github.com/Pink210/SoftBot.git || exit
sleep 2
cd .. || exit
sudo mkdir /bot/
sleep 2
sudo cp -rf /root/SoftBot/ /bot/
sleep 2

# Create the service file with the desired content
sudo tee /etc/systemd/system/softbot.service > /dev/null << 'EOF'
[Unit]
Description=SoftBot

[Service]
Type=simple
ExecStart=/usr/bin/python3 /bot/softbot/main.py
WorkingDirectory=/bot/softbot/
Restart=always

[Install]
WantedBy=sysinit.target
EOF
sleep 2
# Reload the systemd daemon to recognize the new service
sudo systemctl daemon-reload
sleep 2
# Enable the service to start on boot
sudo systemctl enable softbot.service || exit
sleep 3
# Start the service
sudo systemctl start softbot.service || exit
sleep 2

# Restore backup
if [ -d "/opt/backup" ]; then
  echo "Restoring backup."
  sudo systemctl stop SoftBot.service
  sleep 2
  sudo cp -f /bot/backup/msg.py.bak /bot/softether/msg.py 
  sleep 2
  sudo cp -f /bot/backup/setup.py.bak /bot/softether/setup.py 
  sudo systemctl restart SoftBot.service
fi


#add needrestart back again
sudo sed -i "s/#\$nrconf{restart} = 'a';/\$nrconf{restart} = 'i';/" /etc/needrestart/needrestart.conf
clear
echo "Have FUN ;)."

  