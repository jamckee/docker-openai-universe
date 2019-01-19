#!/bin/bash
if [ -e firstrun.md ]; then
 echo "-- First container startup --"
 echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/universe/.mujoco/mjpro150/bin" >> ~/.bashrc
 export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/universe/.mujoco/mjpro150/bin
 
  if [ -n "${DGROUP}" ]; then
    TID="${DGROUP}"
    if [ ${TID} != 999 ]; then
      echo "-- Removing docker group --"
      sudo groupdel docker
      echo "-- Recreating new docker group with id: ${TID} --"
      sudo groupadd --gid ${TID} docker
      echo "-- Readding universe to new docker group --"
      sudo usermod -aG docker universe
    fi
  fi
 echo "-- Running Universe Setup --"
 python3 -m pip install --user gym[all]==0.9.5
 python3 -m pip install --user -e .
 echo "-- Removing firstrun detection file --"
 rm firstrun.md
 echo "-- First run setup complete --"
else
 echo "-- MuJoCo and Full gym already installed --"
fi

echo "-- Tailing /dev/null to leave container running --"
tail -f /dev/null
