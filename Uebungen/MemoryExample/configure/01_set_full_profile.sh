StandaloneXml=$JBOSS_HOME/standalone/configuration/standalone.xml
FullXml=$JBOSS_HOME/standalone/configuration/standalone-full.xml

if [ ! -e ${StandaloneXml}_orig ]; then
	mv $StandaloneXml ${StandaloneXml}_orig
fi

cp $FullXml $StandaloneXml 
