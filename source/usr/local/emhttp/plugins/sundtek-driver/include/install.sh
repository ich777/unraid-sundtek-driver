#!/bin/bash
echo "Making sure that container ${1} is started..."
docker container start ${1} >/dev/null
echo
if [ $(docker inspect ${1} --format='{{.State.ExitCode}}') == 0 ]; then
  echo "Container ${1} started!"
else
  echo "Couldn't start container ${1}!"
  exit 1
fi
echo
echo "Copying sundtek_install.sh to container path /config."
CONFIG_PATH=$(docker inspect --format '{{json .Mounts}}' ${1} | jq -r '.[] | select(.Destination=="/config") | .Source')
cp /boot/config/plugins/sundtek-driver/sundtek_install.sh ${CONFIG_PATH}/sundtek_install.sh >/dev/null
chmod +x ${CONFIG_PATH}/sundtek_install.sh
chown 99:100 ${CONFIG_PATH}/sundtek_install.sh
echo
echo "Checking if Sundtek driver is already installed, please wait..."
echo
docker exec -i ${1} bash -c 'if [ -e "/usr/bin/tvheadend.bin" ]; then exit 1; fi'
if [ $? == 1 ]; then
  echo "Sundtek Driver is already installed in container ${1}, aborting!"
else
  echo "Installing Sundtek driver to container ${1}, please wait..."
  docker exec --env AUTO_INST=1 --env NETINSTALL=0 -i ${1} bash -c '/config/sundtek_install.sh -docker -use-custom-path /config' >/dev/null
  echo
  echo "Restarting container ${1}, please wait..."
  docker container restart ${1} >/dev/null
  echo
  echo "Container ${1} restarted!"
fi
echo
echo "+----------------------------------------------------------------------"
echo "| Please don't forget to pass through the device:"
echo "| /dev/bus/usb"
echo "| in the template, otherwise your tuner(s) will not be recognized!"
echo "| (also check if /dev/dvb is passed through in the template)"
echo "|"
echo "| If you are using a standard TVHeadend container, for example"
echo "| from Linuxserver.io it is also strongly recommended to create"
echo "| a new Path in the template with the following entries:"
echo "|"
echo "| Container Path: /etc/cont-init.d/99-sundtekdriverinstall"
echo "| Host Path: /tmp/sundtek/99-sundtekdriverinstall"
echo "|"
echo "| This will ensure that your tuner(s) are still recognized after a"
echo "| container update."
echo "+----------------------------------------------------------------------"
