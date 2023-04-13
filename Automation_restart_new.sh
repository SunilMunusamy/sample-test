#!/bin/bash

file=$1

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}

logfilename=$(prop 'containerlog')

APP_Containers()
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ]
then
echo "$(prop 'appenv') $i Container is up and running-$(date "+%d%m%Y-%H%M%S")" >> $logfilename
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'appenv') $i Restart was successful-$(date "+%d%m%Y-%H%M%S")" >> $logfilename
                                                        break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'appenv') $i Container is still down-$(date "+%d%m%Y-%H%M%S")" >> $logfilename
                                                                                                echo "$(prop 'appenv') $i Container is down" | mailx -s "$(prop 'appenv') $i Container down" "$(prop 'alertmailid')"

                                fi
                fi
done
fi
return
}

appContainerList=$(prop "appContainerList")
IFS=","
for i in $appContainerList
do
APP_Containers $i
done


ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "bash /usr/appl/pace/home/syspce/Automated_container_restart/Automation_restart.sh $2"

if [ $(ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') 'cat /usr/appl/pace/home/syspce/Automated_container_restart/Restart.log | wc -l') -gt "0" ]
then
IFS=","
for i in $appContainerList
do
docker container restart $i
done
ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "rm -rf /usr/appl/pace/home/syspce/Automated_container_restart/Restart.log && touch /usr/appl/pace/home/syspce/Automated_container_restart/Restart.log"

fi


###########################DB SERVER########################################

#!/bin/bash

file=$1

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}


DB_Containers()
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ] 
then
echo "$(prop 'dbenv') $i Container is up and running" >> /usr/appl/pace/home/syspce/Automated_container_restart/Container_status.log
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'dbenv') $i Restart was successful" | tee /usr/appl/pace/home/syspce/Automated_container_restart/Restart.log >> /usr/appl/pace/home/syspce/Automated_container_restart/Container_status.log
							break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'dbenv') $i Container is still down" >> Container_status.log 
												echo "$(prop 'dbenv') $i Container is down" | mailx -s "$(prop 'dbenv') $i Container down" "$(prop 'alertmailid')"
                                                
                                fi
                fi
done
fi
return
}
dbContainerList=$(prop "dbContainerList")
IFS=","
for i in $dbContainerList
do
DB_Containers $i
done







/usr/appl/pace/home/syspce/Automated_container_restart/Automation_restart.sh /usr/appl/pace/home/syspce/Automated_container_restart/Automation_restart.properties /usr/appl/pace/home/syspce/Automated_container_restart/Automation_restart.properties



##############################################  UAT  #############


#!/bin/bash

file=$1

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}


APP_Containers() 
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ]
then
echo "$(prop 'appenv') $i Container is up and running" >> /usr/appl/pace/home/uatpce/Automated_container_restart/Container_status.log
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'appenv') $i Restart was successful" >> /usr/appl/pace/home/uatpce/Automated_container_restart/Container_status.log
							break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'appenv') $i Container is still down" >> /usr/appl/pace/home/uatpce/Automated_container_restart/Container_status.log
												echo "$(prop 'appenv') $i Container is down" | mailx -s "$(prop 'appenv') $i Container down" swm80@ntrs.com,mm936@ntrs.com,VK386@ntrs.com
                                                
                                fi
                fi
done
fi
return
}

appContainerList=$(prop "appContainerList")
IFS=","
for i in $appContainerList
do
APP_Containers $i
done


ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "bash /usr/appl/pace/home/uatpce/Automated_container_restart/Automation_restart.sh $2"

if [ $(ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') 'cat /usr/appl/pace/home/uatpce/Automated_container_restart/Restart.log | wc -l') -gt "0" ]
then
docker container restart $(prop 'appContainerList')
ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "rm -rf /usr/appl/pace/home/uatpce/Automated_container_restart/Restart.log && touch /usr/appl/pace/home/uatpce/Automated_container_restart/Restart.log"

fi

###########################DB SERVER########################################

#!/bin/bash

file=$1

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}


DB_Containers()
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ] 
then
echo "$(prop 'dbenv') $i Container is up and running" >> /usr/appl/pace/home/uatpce/Automated_container_restart/Container_status.log
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'dbenv') $i Restart was successful" | tee /usr/appl/pace/home/uatpce/Automated_container_restart/Restart.log >> /usr/appl/pace/home/uatpce/Automated_container_restart/Container_status.log
							break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'dbenv') $i Container is still down" >> /usr/appl/pace/home/uatpce/Automated_container_restart/Container_status.log 
												echo "$(prop 'dbenv') $i Container is down" | mailx -s "$(prop 'dbenv') $i Container down" swm80@ntrs.com,mm936@ntrs.com,VK386@ntrs.com
                                                
                                fi
                fi
done
fi
return
}
dbContainerList=$(prop "dbContainerList")
IFS=","
for i in $dbContainerList
do
DB_Containers $i
done

"bash /usr/appl/pace/home/syspce/Automated_container_restart/Automation_restart.sh $2"
/usr/appl/pace/home/uatpce/Automated_container_restart/Automation_restart.sh /usr/appl/pace/home/uatpce/Automated_container_restart/Automation_restart.properties /usr/appl/pace/home/uatpce/Automated_container_restart/Automation_restart.properties



#######################PROD#######################


#!/bin/bash

file=$1

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}

logfilename=$(prop 'containerlog')

APP_Containers() 
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ]
then
echo "$(prop 'appenv') $i Container is up and running" >> $logfilename
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'appenv') $i Restart was successful" >> $logfilename
							break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'appenv') $i Container is still down" >> $logfilename
												echo "$(prop 'appenv') $i Container is down" | mailx -s "$(prop 'appenv') $i Container down" swm80@ntrs.com,mm936@ntrs.com,VK386@ntrs.com
                                                
                                fi
                fi
done
fi
return
}

appContainerList=$(prop "appContainerList")
IFS=","
for i in $appContainerList
do
APP_Containers $i
done


ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "bash /usr/appl/pace/home/prodpce/Automated_container_restart/Automation_restart.sh $2"

if [ $(ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') 'cat /usr/appl/pace/home/prodpce/Automated_container_restart/Restart.log | wc -l') -gt "0" ]
then
IFS=","
for i in $appContainerList
do
docker container restart $i
done
ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "rm -rf /usr/appl/pace/home/prodpce/Automated_container_restart/Restart.log && touch /usr/appl/pace/home/prodpce/Automated_container_restart/Restart.log"

fi



###########DB#########

#!/bin/bash

file=$1

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}

logfilename=$(prop 'containerlog')
DB_Containers()
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ] 
then
echo "$(prop 'dbenv') $i Container is up and running" >> $logfilename
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep -w $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'dbenv') $i Restart was successful" | tee /usr/appl/pace/home/pd9pce9/Automated_container_restart/Restart.log >> $logfilename
							break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'dbenv') $i Container is still down" >> $logfilename
												echo "$(prop 'dbenv') $i Container is down" | mailx -s "$(prop 'dbenv') $i Container down" swm80@ntrs.com,mm936@ntrs.com,VK386@ntrs.com
                                                
                                fi
                fi
done
fi
return
}
dbContainerList=$(prop "dbContainerList")
IFS=","
for i in $dbContainerList
do
DB_Containers $i
done