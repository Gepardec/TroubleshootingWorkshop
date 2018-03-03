#!/bin/sh

INSTANZ=eap7

echo -n "Verwende "
$INSTANZ status | grep JBOSS_HOME
$INSTANZ tear-down
$INSTANZ configure configure
