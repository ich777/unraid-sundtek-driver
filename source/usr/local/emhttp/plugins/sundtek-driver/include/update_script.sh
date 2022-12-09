#!/bin/bash
echo "Updating Sundtek install script, please wait..."
echo
if wget -q -O /boot/config/plugins/sundtek-driver/sundtek_install.sh http://sundtek.de/media/sundtek_netinst.sh ; then
  echo "Successfully updated the Sundtek install script!"
  sed -i "s/NETINSTALL=1/NETINSTALL=0/g" /boot/config/plugins/sundtek-driver/sundtek_install.sh/sundtek_install.sh
else
  echo "Something went wrong with the download from the Sundtek install script!"
  rm -f /boot/config/plugins/sundtek-driver/sundtek_install.sh
  exit 1
fi
echo
echo "+----------------------------------------------------------------------"
echo "| Please close this window and click on 'Install' on the Sundtek Driver"
echo "| Plugin page to copy the new script to the selected Docker container."
echo "|"
echo "| To force an update from the driver inside the TVHeadend container go"
echo "| to the Docker page, enable the Advanced View on the top right corner"
echo "| and click on 'force update' if you have 99-sundtekdriverinstall"
echo "| mounted to the container."
echo "| (Don't forget to disable the Advanced View on the Docker page again)"
echo "+----------------------------------------------------------------------"
