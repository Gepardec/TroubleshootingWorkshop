perl -wpi -e's/-Xms1303m -Xmx1303m/-Xms200m -Xmx200m/' $JBOSS_HOME/bin/standalone.conf
