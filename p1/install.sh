#!/bin/sh
apt-get update
apt-get install vagrant virtualbox vim git make -y
apt-get upgrade
vagrant plugin install vagrant-vbguest
