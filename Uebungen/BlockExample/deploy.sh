#!/bin/sh

INSTANZ=eap

echo -n "Verwende "
$INSTANZ status | grep JBOSS_HOME
$INSTANZ tear-down
$INSTANZ configure configure
