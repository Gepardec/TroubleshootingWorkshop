$JBOSS_HOME/bin/add-user.sh admin admin@123 ManagementRealm --silent=true 

USERS_FILE=$JBOSS_HOME/standalone/configuration/application-users.properties
REALM=ApplicationRealm

USERS=`echo user{0..99}`

:> $USERS_FILE

for USER in $USERS; do
	PWD=$USER
	echo $USER=$( echo -n $USER:$REALM:$PWD | openssl dgst -md5 -hex | cut -d" " -f2 ) >> $USERS_FILE
done
#cat $USERS_FILE

