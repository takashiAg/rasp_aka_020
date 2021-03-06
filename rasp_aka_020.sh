#!/bin/bash
sudo apt-get install -y wvdial usb-modeswitch
echo -e '[Dialer Defaults]\nInit1 = ATZ\nInit2 = AT+CFUN=1\nInit3 = AT+CGDCONT=1,"IP","soracom.io"\nDial Attempts = 3\nModem Type = Analog Modem\nDial Command = ATD\nStupid Mode = yes\nBaud = 460800\nNew PPPD = yes\nModem = /dev/modem\nISDN = 0\nAPN = soracom.io\nPhone = *99***1#\nUsername = sora\nPassword = sora\nCarrier Check = no\nAuto DNS = 1\nCheck Def Route = 1\n'|sudo tee /etc/wvdial.conf

echo -e 'noauth\nname wvdial\nusepeerdns\nreplacedefaultroute\n' | sudo tee /etc/ppp/peers/wvdial

cat /lib/udev/rules.d/40-usb_modeswitch.rules |sed -e '$d' |sudo tee /lib/udev/rules.d/40-usb_modeswitch.rules
echo -e "#ABIT AK-020\nATTRS{idVendor}==\"15eb\", ATTRS{idProduct}==\"a403\", RUN+=\"usb_modeswitch '%b/%k'\"\n\nLABEL=\"modeswitch_rules_end\""|sudo tee -a /lib/udev/rules.d/40-usb_modeswitch.rules
#sudo sed '/^LABEL="modeswitch_rules_end"/i #ABIT AK-020\nATTRS{idVendor}==\"15eb\", ATTRS{idProduct}==\"a403\", RUN+=\"usb_modeswitch "%b/%k"\n' /lib/udev/rules.d/40-usb_modeswitch.rules | sudo tee /lib/udev/rules.d/40-usb_modeswitch.rules

#cat /lib/udev/rules.d/40-usb_modeswitch.rules |sed -e '$d'|

echo -e "DefaultVendor = 0x15eb\nDefaultProduct = 0xa403\nTargetVendor = 0x15eb\nTargetProduct = 0x7d0e\nStandardEject = 1" | sudo tee /etc/usb_modeswitch.d/15eb:a403

cat /etc/rc.local |sed -e '$d' |sed -e '$d' |sudo tee /etc/rc.local
echo  -e "sudo modprobe -v option\n\
echo \"15eb 7d0e\" |sudo tee /sys/bus/usb-serial/drivers/option1/new_id\n\
echo waiting for modem device\n\
for i in {1..30}\n\
do\n\
  [ -e /dev/modem ] && break\n\
  echo -n .\n\
  sleep 1\n\
done\n\
[ \$i = 30 ] && ( echo modem not found ; exit 1 )\n\
sleep 3\n\
wvdial > /home/pi/wvdial.log 2>&1 &\n\
exit 0" | sudo tee -a /etc/rc.local

echo -e "ATTRS{../idVendor}==\"15eb\", ATTRS{../idProduct}==\"7d0e\", ATTRS{bNumEndpoints}==\"03\", ATTRS{bInterfaceNumber}==\"02\", SYMLINK+=\"modem\"" | sudo tee /etc/udev/rules.d/10-soracom.rules

echo -n |sudo tee /home/pi/wvdial.log 
sudo chmod +w /home/pi/wvdial.log