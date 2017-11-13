sudo apt-get install -y wvdial usb-modeswitch
echo -e \
'[Dialer Defaults]\n\
Init1 = ATZ\n\
Init2 = AT+CFUN=1\n\
Init3 = AT+CGDCONT=1,"IP","soracom.io"\n\
Dial Attempts = 3\n\
Modem Type = Analog Modem\n\
Dial Command = ATD\n\
Stupid Mode = yes\n\
Baud = 460800\n\
New PPPD = yes\n\
Modem = /dev/modem\n\
ISDN = 0\n\
APN = soracom.io\n\
Phone = *99***1#\n\
Username = sora\n\
Password = sora\n\
Carrier Check = no\n\
Auto DNS = 1\n\
Check Def Route = 1\n\
'|sudo tee /etc/wvdial.conf

echo 'noauth\n\
name wvdial\n\
usepeerdns\n\
replacedefaultroute\n\
' \
|sudo tee /etc/ppp/peers/wvdial

sudo sed "#ABIT AK-020\nATTRS{idVendor}==\"15eb\", ATTRS{idProduct}==\"a403\", RUN+=\"usb_modeswitch '%b/%k'" /lib/udev/rules.d/40-usb_modeswitch.rules
echo -e "DefaultVendor = 0x15eb\n\
DefaultProduct = 0xa403\n\
TargetVendor = 0x15eb\n\
TargetProduct = 0x7d0e\n\
StandardEject = 1" | sudo tee /etc/usb_modeswitch.d/15eb:a403

echo -e "modprobe -v option\n\
echo \"15eb 7d0e\" > /sys/bus/usb-serial/drivers/option1/new_id\n\
echo waiting for modem device\n\
for i in {1..30}\n\
do\n\
  [ -e /dev/modem ] && break\n\
  echo -n .\n\
  sleep 1\n\
done\n\
[ \$i = 30 ] && ( echo modem not found ; exit 1 )\n\
\n\
sleep 3\n\
wvdial > /home/pi/wvdial.log 2>&1 &" | sudo tee /etc/rc.local

echo -e "ATTRS{../idVendor}==\"15eb\", ATTRS{../idProduct}==\"7d0e\", ATTRS{bNumEndpoints}==\"03\", ATTRS{bInterfaceNumber}==\"02\", SYMLINK+=\"modem\"" | sudo tee /etc/udev/rules.d/10-soracom.rules

