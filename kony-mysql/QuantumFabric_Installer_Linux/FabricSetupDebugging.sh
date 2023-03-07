#!/usr/bin/env
getInputs()
{
INSTALLATION_PATH="$(pwd)"
if [ ! -f $INSTALLATION_PATH/config.properties ]; then
    Install_mode="ONPREM"
else
	Install_mode="CONTAINER"
fi

if [ -f $INSTALLATION_PATH/generate-kube-artifacts.sh ] && [ ! -d $INSTALLATION_PATH/samples ]; then
	command="oc"
else
	command='sudo kubectl'
fi
}

freeDiskSpace()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking disk availability ######################(20%)\r'
	sleep 1
	echo -ne 'Checking disk availability #################################    (45%)\r'
	sleep 2
	echo -ne 'Checking disk availability ########################################  (75%)\r'
	sleep 3
	echo -ne 'Checking disk availability #############################################################   (100%)\r'

	sleep 2
   	echo -ne '\n'


  # spaceAvailable=$(df -h| grep $(echo ${INSTALLATION_PATH} | cut -d '/' -f 2) | cut -d " " -f 4 | cut -d 'G' -f 1)
   spaceAvailable=$(df --output=avail -h "$PWD" | tail -1 | cut -d G -f 1)
   if [ ${spaceAvailable} -gt 10 ];
   then
		echo -ne '\n'
		echo "Disk space available : ${spaceAvailable}GB"
   else
		echo -ne '\n'
		echo "Disk space unavailable, Please cleanup some space"
   fi
}

portAvailability()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking Port availability ######################(20%)\r'
	sleep 1
	echo -ne 'Checking Port availability #################################    (55%)\r'
	sleep 2
	echo -ne 'Checking Port availability ########################################  (85%)\r'
	sleep 3
	echo -ne 'Checking Port availability #############################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	hostname1=$(grep -w "CONSOLE_HOST_DETAILS=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($2,1,length($2)-1)'})
	portnumber=$(grep -w "CONSOLE_HOST_DETAILS=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($4,1,length($4)-1)'})
	echo -ne '\n'
	echo "Hostname: $hostname1" 
	echo -ne '\n'
	echo "Port: $portnumber" 
	echo -ne '\n'
	sudo netstat -anp | grep "${portnumber}"
	echo -ne '\n'
	sleep 5s
	#sudo telnet $hostname1 $portnumber 2>&1 | tee -a -i
	RESPONSE=$(timeout 3 telnet $hostname1 $portnumber)
	echo "Port: $RESPONSE"
	   
 
}

function installationCheck()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking Fabric installation ######################(20%)\r'
	sleep 1
	echo -ne 'Checking Fabric installation #################################    (55%)\r'
	sleep 2
	echo -ne 'Checking Fabric installation ########################################  (85%)\r'
	sleep 3
	echo -ne 'Checking Fabric installation ###########################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	status=$(find "${INSTALLATION_PATH}"/* -maxdepth 0 -type d 2> /dev/null | wc -l )
	if [ ${status} -gt 6 ];
	then
		return 1
	elif [ ${status} -le 0 ];
	then
	   	return 0
	fi


}

errorLogDisplay()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking failure reason ######################(20%)\r'
	sleep 1
	echo -ne 'Checking failure reson #################################    (55%)\r'
	sleep 2
	echo -ne 'Checking failure reason ########################################  (85%)\r'
	sleep 3
	echo -ne 'Checking failure reason ################################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	echo -ne '\n'
	echo -ne '\n'
	errorLog="Error occurred while installing the following Action,"
	#echo "${errorLog}"
	logfileName=$(basename $INSTALLATION_PATH/Quantum_Fabric_Install_*.log)
	errorMessage=$(grep -A 24 "${errorLog}" "${INSTALLATION_PATH}/${logfileName}")
	echo "${errorMessage}"
	echo -ne '\n'
	echo -ne '*************************************************************************************************\n'
	echo -ne '\n'

}

validateJava()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking Java availability ######################(25%)\r'
	sleep 1
	echo -ne 'Checking Java availability #################################    (50%)\r'
	sleep 2
	echo -ne 'Checking Java availability ########################################  (80%)\r'
	sleep 3
	echo -ne 'Checking Java availability #############################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	echo -ne '\n'
	sudo java -version 
	echo -ne '\n'
	echo -e " ALERT : 9.x Fabric version must be run with JAVA 11 . . . . ." 
	echo -ne '\n'


}


serverstatus()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking server status ######################(25%)\r'
	sleep 1
	echo -ne 'Checking server status #################################    (65%)\r'
	sleep 2
	echo -ne 'Checking server status ########################################  (85%)\r'
	sleep 3
	echo -ne 'Checking server status #################################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	FILE=$(ls "${INSTALLATION_PATH}" | grep ".log$" | head -1)
	#appserv=$(grep -w "USER_INPUT_SERVER_CHOICE=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($2,1,length($2)-1)'})
	appserv=$(grep -w "USER_INPUT_SERVER_CHOICE=" "${INSTALLATION_PATH}"/"${FILE}" | awk -F '\"' {'print substr($2,1,length($2)-1)'})
	
	echo -ne '\n'
	echo "Application Server : $appserv"
	echo -ne '\n'
	TOMCAT_PID=$(ps -ef | awk '/[t]omcat/{print $2}')

	if [ -z "$TOMCAT_PID" ]
	then
	    echo "Application Server status: TOMCAT NOT RUNNING"
	    #sudo /opt/tomcat/bin/startup.sh
	else	
	   echo "Application Server status: TOMCAT RUNNING"
	fi 


}

fabricStatusCheck()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking Installation status ######################(25%)\r'
	sleep 1
	echo -ne 'Checking Installation status #################################    (65%)\r'
	sleep 2
	echo -ne 'Checking Installation status ########################################  (85%)\r'
	sleep 3
	echo -ne 'Checking Installation status ###########################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	echo -ne '\n'
	status=$(find "${INSTALLATION_PATH}"/* -maxdepth 0 -type d 2> /dev/null | wc -l )
	
	basename -a "${INSTALLATION_PATH}"/* 2> /dev/null
	out=$(basename "${INSTALLATION_PATH}"/*)
	grep -w "Installation:" "${INSTALLATION_PATH}"/$out | cut -d " " -f2

}

fabricHealthCheck()
{
	echo -ne '\n'
	echo -ne '\t \t \t * * * * CHECKING Fabric Health * * * *  \n'
	echo -ne '\n'
	echo -ne ' **********************************************************************************************  \n'
	sleep 2s
	protocol1=$(grep -w "USER_INPUT_PROTOCOL=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($2,1,length($2)-1)'})
	hostname1=$(grep -w "CONSOLE_HOST_DETAILS=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($2,1,length($2)-1)'})
	portnumber=$(grep -w "CONSOLE_HOST_DETAILS=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($4,1,length($4)-1)'})
	
	accountshealth=$(curl $protocol1://$hostname1:$portnumber/accounts/health_check) 
	consolehealth=$(curl $protocol1://$hostname1:$portnumber/mfconsole/health_check/all) 
	adminhealth=$(curl $protocol1://$hostname1:$portnumber/admin/healthcheck) 
	authhealth=$(curl $protocol1://$hostname1:$portnumber/authService/)
	Engagement=$(curl $protocol1://$hostname1:$portnumber/kpns/service/healthcheck/json) 

	echo -ne '\n'
	echo -ne 'Checking Identity service health ######################(20%)\r'
	sleep 1
	echo -ne 'Checking Identity service health #################################    (50%)\r'
	sleep 2
	echo -ne 'Checking Identity service health ########################################  (75%)\r'
	sleep 3
	echo -ne 'Checking Identity service health #######################################################   (100%)\r'
	echo -ne '\n'
	sleep 2

		if [ "${authhealth}" = "Welcome to Test Auth Service" ];
	then
		echo -ne '\n'
		echo -ne '\t Identity Health Check successful \n'
	
	else
		echo -ne '\n'
		echo -ne '\t ERROR : Identity Health Check fail \n'
		echo -ne '\n'
		
	fi

	echo -ne '\n'
	echo -ne 'Checking Accounts service health ######################(25%)\r'
	sleep 1
	echo -ne 'Checking Accounts service health #################################    (50%)\r'
	sleep 2
	echo -ne 'Checking Accounts service health ########################################  (80%)\r'
	sleep 3
	echo -ne 'Checking Accounts service health #######################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	word=$(echo -n "$accountshealth" | wc -w)
	if [ "${word}" == "2" ];
	then
		echo -ne '\n'
		echo -ne '\t Accounts Health Check successful \n'
		echo -ne '\n'
		echo "$accountshealth"
	
	else
		echo -ne '\n'
		echo -ne '\t ERROR : Accounts Health Check fail \n'
		echo -ne '\n'
		echo "$accountshealth"
		
	fi


	echo -ne '\n'
	echo -ne 'Checking Console service health ######################(15%)\r'
	sleep 1
	echo -ne 'Checking Console service health #################################    (45%)\r'
	sleep 2
	echo -ne 'Checking Console service health ########################################  (75%)\r'
	sleep 3
	echo -ne 'Checking Console service health ########################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	word2=$(echo -n "$consolehealth" | wc -w)
	if [ "${word2}" == "1" ];
	then
		echo -ne '\n'
		echo -ne '\t Console Health Check successful \n'
		echo -ne '\n'
		echo "$consolehealth"
	
	else
		echo -ne '\n'
		echo -ne '\t ERROR : Console Health Check fail \n'
		echo -ne '\n'
		

	fi
	echo -ne '\n'
	echo -ne 'Checking Middleware service health ######################(20%)\r'
	sleep 1
	echo -ne 'Checking Middleware service health #################################    (60%)\r'
	sleep 2
	echo -ne 'Checking Middleware service health ########################################  (80%)\r'
	sleep 3
	echo -ne 'Checking Middleware service health #####################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	word3=$(echo -n "$adminhealth" | wc -w)
	if [ "${word3}" == "1004" ];
	then
		echo -ne '\n'
		echo -ne '\t Middleware Health Check successful \n'
		echo -ne '\n'
	
	else
		echo -ne '\n'
		echo -ne '\t ERROR : Middleware Health Check fail \n'
		echo -ne '\n'
		
	fi
	echo -ne '\n'
	echo -ne 'Checking Engagement service health ######################(15%)\r'
	sleep 1
	echo -ne 'Checking Engagement service health #################################    (45%)\r'
	sleep 2
	echo -ne 'Checking Engagement service health ########################################  (75%)\r'
	sleep 3
	echo -ne 'Checking Engagement service health #####################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	word3=$(echo -n "$Engagement" | wc -w)
	if [ "${word3}" == "6" ];
	then
		echo -ne '\n'
		echo -ne '\t Engagement Health Check successful \n'
		echo -ne '\n'
		echo "$Engagement"
	
	else
		echo -ne '\n'
		echo -ne '\t ERROR : Engagement Health Check fail \n'
		echo -ne '\n'
		echo "$Engagement"
	fi
	echo -ne '\n'
	echo -ne ' *****************************************************************************************  \n'



}

fileCapture()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking logs info ######################(25%)\r'
	sleep 1
	echo -ne 'Checking logs info #################################    (55%)\r'
	sleep 2
	echo -ne 'Checking logs info ########################################  (84 %)\r'
	sleep 3
	echo -ne 'Checking logs info #####################################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	if [ -d "/tmp" ] ; 
	then
    		sudo rm -rf /tmp/Fabriclogs
		sudo rm -rf /tmp/Fabriclogs.zip
		mkdir /tmp/Fabriclogs
	else
   		mkdir /tmp/Fabriclogs
	fi
	echo -ne '\n'
	echo -ne '\n'
	status=$(find "${INSTALLATION_PATH}"/* -maxdepth 0 -type d 2> /dev/null | wc -l )
	if [ ${status} -gt 6 ];
	then
		cp -R ${INSTALLATION_PATH}/tomcat/logs/*.* /tmp/Fabriclogs
		cp -R ${INSTALLATION_PATH}/logs/*.* /tmp/Fabriclogs
		cp -R ${INSTALLATION_PATH}/*.* /tmp/Fabriclogs
	elif [ ${status} -le 0 ];
	then
	   	cp -R ${INSTALLATION_PATH}/*.* /tmp/Fabriclogs
	fi

	sleep 1s
	cd /tmp
	zip Fabriclogs.zip /tmp/Fabriclogs/
	echo -ne '\t \t \t * * * Finalizing and collecting data * * * '
	echo -ne '\n'
	echo -ne '\n'
	progress_bar 40
	echo -ne '\n'
	echo -ne '\n'
	sleep 1s
	echo -ne '\t \t * * * Please share Fabriclogs.zip at /tmp directory * * * \n'
	echo -ne '\n'
	echo -ne '\n'
	sleep 2s




}

databaseDetails()
{
	echo -ne '\n'
	echo -e ''
	echo -ne 'Checking DB availability ######################(20%)\r'
	sleep 1
	echo -ne 'Checking DB availability #################################    (50%)\r'
	sleep 2
	echo -ne 'Checking DB availability ########################################  (80%)\r'
	sleep 3
	echo -ne 'Checking DB availability #############################################################   (100%)\r'
	echo -ne '\n'
	sleep 2
	dbname=$(grep -w "CONSOLE_DB_CHOICE=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($2,1,length($2)-1)'})
	dbhost=$(grep -w "CONSOLE_DB_DETAILS=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($2,1,length($2)-1)'})
	dbport=$(grep -w "CONSOLE_DB_DETAILS=" "${INSTALLATION_PATH}"/*.log | awk -F '\"' {'print substr($4,1,length($4)-1)'})
	echo -ne '\n'
	echo "DB Type: $dbname" 

	echo -ne '\n'
	echo "DB Hostname: $dbhost" 
	echo -ne '\n'
	echo "DB Port: $dbport" 
	echo -ne '\n'
	#sudo netstat -an|grep "${dbport}"
	echo -ne '\n'
	sleep 5s
	#sudo telnet $dbhost $dbport 2>&1 | tee -a -i
	RESPONSE=$(timeout 3 telnet $dbhost $dbport)
	echo "DB Connection status: $RESPONSE"
	echo -ne '\n'
	   
 
}


progress_bar()
{
  local DURATION=$1
  local INT=0.25      # refresh interval

  local TIME=0
  local CURLEN=0
  local SECS=0
  local FRACTION=0

  local FB=2588       # full block

  trap "echo -e $(tput cnorm); trap - SIGINT; return" SIGINT

  echo -ne "$(tput civis)\r$(tput el)¦"                # clean line

  local START=$( date +%s%N )

  while [ $SECS -lt $DURATION ]; do
    local COLS=$( tput cols )

    # main bar
    local L=$( bc -l <<< "( ( $COLS - 5 ) * $TIME  ) / ($DURATION-$INT)" | awk '{ printf "%f", $0 }' )
    local N=$( bc -l <<< $L                                              | awk '{ printf "%d", $0 }' )

    [ $FRACTION -ne 0 ] && echo -ne "$( tput cub 1 )"  # erase partial block

    if [ $N -gt $CURLEN ]; then
      for i in $( seq 1 $(( N - CURLEN )) ); do
        echo -ne \\u$FB
      done
      CURLEN=$N
    fi

    # partial block adjustment
    FRACTION=$( bc -l <<< "( $L - $N ) * 8" | awk '{ printf "%.0f", $0 }' )

    if [ $FRACTION -ne 0 ]; then 
      local PB=$( printf %x $(( 0x258F - FRACTION + 1 )) )
      echo -ne \\u$PB
    fi

    # percentage progress
    local PROGRESS=$( bc -l <<< "( 100 * $TIME ) / ($DURATION-$INT)" | awk '{ printf "%.0f", $0 }' )
    echo -ne "$( tput sc )"                            # save pos
    echo -ne "\r$( tput cuf $(( COLS - 6 )) )"         # move cur
    echo -ne "¦ $PROGRESS%"
    echo -ne "$( tput rc )"                            # restore pos

    TIME=$( bc -l <<< "$TIME + $INT" | awk '{ printf "%f", $0 }' )
    SECS=$( bc -l <<<  $TIME         | awk '{ printf "%d", $0 }' )

    # take into account loop execution time
    local END=$( date +%s%N )
    local DELTA=$( bc -l <<< "$INT - ( $END - $START )/1000000000" \
                   | awk '{ if ( $0 > 0 ) printf "%f", $0; else print "0" }' )
    sleep $DELTA
    START=$( date +%s%N )
  done

  echo $(tput cnorm)
  trap - SIGINT
}



#Container methods



dbMigrationsCheck()
{
   dbPodname=$($1 get pods | grep "kony-fabric-db*" | awk '{print $1}')
   dbPodStatus=$($1 get pods | grep "kony-fabric-db*" | awk '{print $3}')
   #echo $dbPodname
   #echo $dbPodStatus
	echo -ne '\n'
	echo -ne ' **********************************************************************************************  \n'
	echo -ne '\n'
	echo -ne '\t \t \t * * * * CHECKING DB Migrations Status * * * *  \n'
	echo -ne '\n'
	echo -ne ' **********************************************************************************************  \n'
	sleep 2s
	if [ "${dbPodStatus}" = "Completed" ];
	then
		echo -ne '\n'
		decorator "Checking DB Migrations status" "DB Migrations successful"
		return 1
	else
		decorator "Checking DB Migrations status" "DB Migrations failed "
		sleep 10s
		echo -ne '\n'
		echo -ne "\t Reason for failure"	
		echo $($1 describe pod ${dbPodname} | grep -A 25 "Events")
	fi

}

containerinstallationCheck()
{
	echo -ne '\n'
	echo -ne ' **********************************************************************************************  \n'
	echo -ne '\n'
	echo -ne '\t \t \t * * * * CHECKING Fabric Component Deployment Status * * * *  \n'
	echo -ne '\n'
	echo -ne ' **********************************************************************************************  \n'
	sleep 2s
	apiportalPodname=$($1 get pods | grep "kony-fabric-apiportal*" | awk '{print $1}')
	apiportalPodStatus=$($1 get pods | grep "kony-fabric-apiportal*" | awk '{print $3}')
   
	consolePodname=$($1 get pods | grep "kony-fabric-console*" | awk '{print $1}')
	consolePodStatus=$($1 get pods | grep "kony-fabric-console*" | awk '{print $3}')
   
	engagementPodname=$($1 get pods | grep "kony-fabric-engagement*" | awk '{print $1}')
	engagementPodStatus=$($1 get pods | grep "kony-fabric-engagement*" | awk '{print $3}')
   
	identityPodname=$($1 get pods | grep "kony-fabric-identity*" | awk '{print $1}')
	identityPodStatus=$($1 get pods | grep "kony-fabric-identity*" | awk '{print $3}')
   
	integrationPodname=$($1 get pods | grep "kony-fabric-integration*" | awk '{print $1}')
	integrationPodStatus=$($1 get pods | grep "kony-fabric-integration*" | awk '{print $3}')
	
	
	if [[ ${apiportalPodStatus} == "Running" && ${consolePodStatus} == "Running" && ${engagementPodStatus} == "Running" && ${identityPodStatus} == "Running" && ${integrationPodStatus} == "Running" ]]; then
		decorator "Checking APIPORTAL deployment status" "APIPORTAL deployment Success"
		decorator "Checking CONSOLE deployment status" "CONSOLE deployment Success"
		decorator "Checking ENGAGEMENT deployment status" "ENGAGEMENT deployment Success"
		decorator "Checking IDENTITY deployment status" "IDENTITY deployment Success"
		decorator "Checking INTEGRATION deployment status" "INTEGRATION deployment Success"
		return 1
		
	else
		if [[ ${apiportalPodStatus} != "Running" ]]; then
			#echo "******************************* APIPORTAL failed to deploy "
			decorator "Checking APIPORTAL deployment status"  "APIPORTAL deployment Failed"
			sleep 10s
			echo -ne '\n'
		    echo -ne "Reason for failure"
			echo -ne '\n'
			echo $($1 describe pod ${apiportalPodname} | grep -A 25 "Events")
		fi
		if [[ ${consolePodStatus} != "Running" ]]; then
			#echo "******************************* CONSOLE failed to deploy "
			decorator "Checking CONSOLE deployment status" "CONSOLE deployment Failed"
			sleep 10s
			echo -ne '\n'
		    echo -ne "Reason for failure"
			echo -ne '\n'
			echo $($1 describe pod ${consolePodname} | grep -A 25 "Events")
		fi		
		if [[ ${engagementPodStatus} != "Running" ]]; then
			#echo "******************************* ENGAGEMENT failed to deploy "
			decorator "Checking ENGAGEMENT deployment status" "ENGAGEMENT deployment Failed"
			sleep 10s
			echo -ne '\n'
		    echo -ne "Reason for failure"
			echo -ne '\n'
			echo $($1 describe pod ${engagementPodname} | grep -A 25 "Events")
		fi			
		if [[ ${identityPodStatus} != "Running" ]]; then
			#echo "******************************* IDENTITY failed to deploy "
			decorator "Checking IDENTITY deployment status" "IDENTITY deployment status Failed"
			sleep 10s
			echo -ne '\n'
		    echo -ne "Reason for failure"
			echo -ne '\n'
			echo $($1 describe pod ${identityPodname} | grep -A 25 "Events")
		fi	
		if [[ ${integrationPodStatus} != "Running" ]]; then
			#echo "******************************* INTEGRATION failed to deploy "
			decorator "Checking INTEGRATION deployment status" "INTEGRATION deployment Failed"
			sleep 10s
			echo -ne '\n'
		    echo -ne "Reason for failure"
			echo -ne '\n'
			echo $($1 describe pod ${integrationPodname} | grep -A 25 "Events")
		fi
		return 0
	fi

}
decorator()
{
		echo -ne '\n'
		echo -e ''
		echo -ne " $1  ######################(20%)\r"
		sleep 1
		echo -ne " $1  #################################    (50%)\r"
		sleep 2
		echo -ne " $1  ########################################  (80%)\r"
		sleep 3
		echo -ne " $1  #############################################################   (100%)\r"
		echo -ne '\n'
		sleep 2
		echo -ne "\t $2"
}

fabricContainerHealthCheck()
{
	echo -ne '\n'
	echo -ne ' ********************************************************************************************** \n'
	echo -ne '\n'
	echo -ne '\t \t \t * * * * CHECKING Fabric Health * * * *  \n'
	echo -ne '\n'
	echo -ne ' **********************************************************************************************  \n'
	sleep 2s
	protocol1=$($1 describe cm kony-fabric-console-conf | grep -A 2 HTTP_PROTOCOL | tail -1)
	hostname1=$($1 describe cm kony-fabric-console-conf | grep -A 2 DOCKER_HOST | tail -1)
	portnumber=80
	
	#url = $protocol1://$hostname1:$portnumber
	
	accountshealth=$(curl -s $protocol1://$hostname1:$portnumber/accounts/health_check) 
	consolehealth=$(curl -s $protocol1://$hostname1:$portnumber/mfconsole/health_check/all) 
	adminhealth=$(curl -s $protocol1://$hostname1:$portnumber/admin/healthcheck) 
	authhealth=$(curl -s $protocol1://$hostname1:$portnumber/authService/)
	Engagement=$(curl -s $protocol1://$hostname1:$portnumber/kpns/service/healthcheck/json)
	
	

	if [ "${authhealth}" = "Welcome to Test Auth Service" ];then
		echo -ne '\n'
		decorator "Checking Identity service health" "Identity Health Check successful"
		echo -ne '\n'
		echo "$(curl -s $protocol1://$hostname1:$portnumber/authService/v1/manage/checkhealth)"
	
	else
		echo -ne '\n'
		decorator "Checking Identity service health"  "ERROR : Identity Health Check fail"
		echo -ne '\n'
		echo "$(curl -s $protocol1://$hostname1:$portnumber/authService/v1/manage/checkhealth)"
	fi

	
	word=$(echo -n "$accountshealth" | wc -w)
	if [ "${word}" == "2" ];
	then
		echo -ne '\n'
		decorator "Checking Accounts service health" "Accounts Health Check successful"
		echo -ne '\n'
		echo "$accountshealth"
	
	else
		echo -ne '\n'
		decorator "Checking Accounts service health" "ERROR : Accounts Health Check failed"
		echo -ne '\n'
		echo "$accountshealth"
		
	fi


	word2=$(echo -n "$consolehealth" | wc -w)
	if [ "${word2}" == "1" ];
	then
		echo -ne '\n'
		decorator "Checking Console service health" "Console Health Check successful"
		echo -ne '\n'
		echo "$consolehealth"
	
	else
		echo -ne '\n'
		decorator "Checking Console service health" "ERROR : Console Health Check fail"
		echo -ne '\n'
		echo "$consolehealth"
		

	fi

	word3=$(echo -n "$adminhealth" | wc -w)
	if [ "${word3}" == "1004" ];
	then
		echo -ne '\n'
		decorator "Checking Middleware service health" "Middleware Health Check successful"
		echo -ne '\n'
		echo "$(curl -s  $protocol1://$hostname1:$portnumber/admin/healthcheck?output=json)"
	
	else
		echo -ne '\n'
		decorator "Checking Middleware service health" "ERROR : Middleware Health Check fail"
		echo -ne '\n'
		echo "$(curl -s  $protocol1://$hostname1:$portnumber/admin/healthcheck?output=json)"
		
	fi
	
	word3=$(echo -n "$Engagement" | wc -w)
	if [ "${word3}" == "6" ];
	then
		echo -ne '\n'
		decorator "Checking Engagement service health" "Engagement Health Check successful"
		echo -ne '\n'
		echo "$Engagement"
	
	else
		echo -ne '\n'
		decorator "Checking Engagement service health" "ERROR : Engagement Health Check fail"
		echo -ne '\n'
		echo "$Engagement"
	fi
	echo -ne '\n'
	echo -ne ' *****************************************************************************************  \n'
}
is_command_present() {
	# https://stackoverflow.com/a/677212/340290
	hash "$1" 2>/dev/null ;
	# command -v "$1" >/dev/null 2>&1 ;
}

is_docker_command_present(){
	if is_command_present docker; then
	    decorator "Checking for docker availability" " $(docker -v)\n"
		#echo -e "Docker $(docker -v)\n"
	else
	    decorator "Checking for docker availability" "Docker not installed before installation of Fabric"	
		#echo -e "Docker not installed before installation of Fabric\n"
	fi
}

is_kubectl_command_present(){
	if is_command_present kubectl; then
	    decorator "Checking for KUBECTL availability" "KUBECTL $(kubectl version --short 2>&1 | head -n 1)\n"
		#echo -e "KUBECTL $(kubectl version --short 2>&1 | head -n 1)\n" 
	else
	    decorator "Checking for KUBECTL availability" "KUBECTL is not installed before installation of Fabric"	
		#echo -e "KUBECTL is not installed before installation of Fabric\n" 
	fi
}

is_kubelet_command_present(){
	if is_command_present kubelet; then
	    decorator "Checking for KUBELET availability" "KUBELET Client Version: $(kubelet --version | awk '{print $2;}')"	
		#echo -e "KUBELET Client Version: $(kubelet --version | awk '{print $2;}')" 
	else
	    decorator "Checking for KUBELET availability" "KUBELET is not installed before installation of Fabric"	
		#echo -e "KUBELET is not installed before installation of Fabric" 
	fi
}

is_kubeadm_command_present(){
	if is_command_present kubeadm; then
	    decorator "Checking for KUBEADM availability" "KUBEADM Client Version: $(kubeadm version -o short)"	
		#echo -e "KUBEADM Client Version: $(kubeadm version -o short)" 
	else
	    decorator "Checking for KUBEADM availability" "KUBEADM is not installed before installation of Fabric"		
		#echo -e "KUBEADM is not installed before installation of Fabric" 
	fi
}

is_oc_command_present(){
	if is_command_present oc; then
	    decorator "Checking for OpenShift CLI availability" "OpenShift CLI $(oc version  2>&1 | head -n 1)\n"	
		#echo -e "OpenShift CLI $(oc version  2>&1 | head -n 1)\n" 
	else
	    decorator "Checking for OpenShift CLI availability" "OpenShift CLI is not installed before installation of Fabric\n"			
		#echo -e "OpenShift CLI is not installed before installation of Fabric\n" 
	fi
}
containerFileCapture()
{
	if [ -d "/tmp/Fabriclogs" ] ; 
	then
    	sudo rm -rf /tmp/Fabriclogs
		sudo rm -rf /tmp/Fabriclogs.zip
		mkdir /tmp/Fabriclogs
	else
   		mkdir /tmp/Fabriclogs
	fi
	
	sudo cp -r $INSTALLATION_PATH/logs /tmp/Fabriclogs/ &> /dev/null
	sudo cp -r $INSTALLATION_PATH/gen /tmp/Fabriclogs/ &> /dev/null
	sudo cp -r $INSTALLATION_PATH/artifacts /tmp/Fabriclogs/  &> /dev/null
	sleep 1s
	cd /tmp
	zip Fabriclogs.zip /tmp/Fabriclogs/
	echo -ne '\t \t \t * * * Finalizing and collecting data * * * '
	echo -ne '\n'
	echo -ne '\n'
	progress_bar 40
	echo -ne '\n'
	echo -ne '\n'
	sleep 1s
	echo -ne '\t \t * * * Please share Fabriclogs.zip at /tmp directory * * * \n'
	echo -ne '\n'
	echo -ne '\n'
	sleep 2s
}


getInputs


if [ $Install_mode == "ONPREM"  ];
then
	echo -ne '\n'
	echo -ne '\t \t ******************************* Debugging process started ******************************* \n'
	echo -ne '\n'
	sleep 2s
	installationCheck
	installation_status=$?
	
	if [ ${installation_status} == 1 ];then
		serverstatus
		databaseDetails
		fabricHealthCheck
		fileCapture
		
            fi
	if [ ${installation_status} == 0 ];then
		fabricStatusCheck
		freeDiskSpace
		validateJava
		portAvailability
		serverstatus
		errorLogDisplay
		fileCapture
	fi
elif [ $Install_mode == "CONTAINER" ];
then
	echo -ne '\n'
	#echo -ne '\t * * * * Sanity Check for OnPrem native container FabricInstaller * * * *'
	echo -ne '\t \t \t * * * * Sanity Check for FabricInstaller * * * *  \n'
	echo -ne '\n'
	dbMigrationsCheck "${command}"
	dbStatus=$?
	if [ $dbStatus == 1 ];then
		containerinstallationCheck "${command}"
	else
	    containerFileCapture "${command}"
		exit 1
	fi
	container_installation_status=$?
	if [ ${container_installation_status} == 1 ];then
		fabricContainerHealthCheck "${command}"
		containerFileCapture "${command}"	
	fi
	if [ ${container_installation_status} == 0 ]; then
	echo -ne '\n'
	echo -ne ' ********************************************************************************************** \n'
	echo -ne '\n'
	echo -ne '\t \t \t * * * * FabricInstallation Failed * * * *  \n'
	echo -ne '\n'
	echo -ne '\t \t \t * * * * Failure Sanity Check * * * *  \n'
	echo -ne '\n'
	echo -ne ' **********************************************************************************************  \n'
	sleep 2s	
	echo -ne '\n'	

	echo -ne '\n'	
		freeDiskSpace
		validateJava
		is_docker_command_present
		if [ "${command}" != "oc" ]; then
			is_kubectl_command_present
			is_kubelet_command_present
			is_kubeadm_command_present
			containerFileCapture "${command}"
		else
		    is_oc_command_present
			containerFileCapture "${command}"
		fi
	fi
fi
