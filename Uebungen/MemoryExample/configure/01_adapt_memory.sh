perl -wpi -e's/-Xms1303m -Xmx1303m/-Xms300m -Xmx300m/' $JBOSS_HOME/bin/standalone.conf
