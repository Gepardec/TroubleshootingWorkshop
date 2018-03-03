perl -wpi -e's/-Xms1303m -Xmx1303m/-Xms512m -Xmx512m/' $JBOSS_HOME/bin/standalone.conf
