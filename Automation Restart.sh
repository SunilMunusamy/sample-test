#!/bin/bash

file="./Automation Restart.properties"

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}


APP_Containers() 
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ]
then
echo "$(prop 'appenv') $i Container is up and running" >> Container_status.log
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'appenv') $i Restart was successful" >> Container_status.log
							break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'appenv') $i Container is still down" >> Container_status.log
												echo "$(prop 'appenv') $i Container is down" | mailx -s "$(prop 'appenv') $i Container down" swm80@ntrs.com,mm936@ntrs.com
                                                
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


sshpass -p $(prop 'dbServerPassword') ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "./restart.sh $2"

if [ $(sshpass -p $(prop 'dbServerPassword') ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') 'cat Restart.log | wc -l') -gt "0" ]
then
docker container restart $(prop 'appContainerList')
sshpass -p $(prop 'dbServerPassword') ssh $(prop 'dbServerUserName')@$(prop 'dbServerHostName') "rm -rf Restart.log && touch Restart.log"

fi

###########################DB SERVER########################################

#!/bin/bash

file="$1"

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}


DB_Containers()
{
cntrnm=$1
#Check if the container is running
cntrcnt=`docker container ls -a | grep $cntrnm | grep "Up" | wc -l`
if [ $cntrcnt -eq 1 ] 
then
echo "$(prop 'dbenv') $i Container is up and running" >> Container_status.log
else
for a in 1 2 3
do
                docker container restart $cntrnm
                cntrcnt=`docker container ls -a | grep $cntrnm | grep "Up" | wc -l`
                if [ $cntrcnt -eq 1 ]
                then
                                echo "$(prop 'dbenv') $i Restart was successful" | tee Restart.log >> Container_status.log
							break
                else
                                if [ $a -eq 3 ]
                                then
                                                echo "Restarted 3 times and $(prop 'dbenv') $i Container is still down" >> Container_status.log 
												echo "$(prop 'dbenv') $i Container is down" | mailx -s "$(prop 'dbenv') $i Container down" swm80@ntrs.com,mm936@ntrs.com
                                                
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



#!/bin/bash

file=$1

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}

#Append date stamp to file
file_name=graph.db-backup
current_time=$(date "+%Y%m%d-%H%M%S")
new_fileName=$current_time.$file_name

#taking the backup of Neo4j
echo "*************Database Backup Started**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*************Database Backup Started**************"
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j backup started."
ssh $(prop 'D_UserName')@$(prop 'D_IPAddress') "bash "
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j backup completed."
echo "************Database Backup Completed*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "************Database Backup Completed*************"

echo ""

#taking the application backup 
echo "************Application Backup Started************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "************Application Backup Started************"
#creating the directory and copying the backup data.
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App backup started."
mkdir -p $(prop 'applicationBackupFolder')/$current_time 
docker cp $(prop 'applicationDockerContainerName'):$(prop 'applicationContainerPath')/$(prop 'applicationname') $(prop 'applicationBackupFolder')/$current_time/
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App backup completed."

#taking the Dataload service backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup started."
docker cp $(prop 'dataloadDockerContainerName'):$(prop 'dataloadContainerPath')/$(prop 'dataLoadEngineName') $(prop 'applicationBackupFolder')/$current_time/
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup completed."

#taking the RuleEngine Service backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup started."
docker cp $(prop 'ruleEngineDockerContainerName'):$(prop 'ruleEngineContainerPath')/$(prop 'ruleEngineName') $(prop 'applicationBackupFolder')/$current_time/ 
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup completed."

#taking the nFlowsExportAPI Service backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup started."
docker cp $(prop 'exportAPIDockerContainerName'):$(prop 'exportAPIContainerPath')/$(prop 'exportAPIName') $(prop 'applicationBackupFolder')/$current_time/
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup completed."
echo "**********Application Backup Completed************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Application Backup Completed************"

echo ""

#taking the Configfiles backup
echo "************Config File Backup Started************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "************Config File Backup Started************"
#creating the directory and copying the backup data.
mkdir $(prop 'configurationFileFolder')
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App Config File backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App Config File backup started."
mkdir $(prop 'configurationFileFolder')/$(prop 'applicationConfigfileBackup')
cp -r $(prop 'applicationBackupFolder')/$current_time/$(prop 'applicationConfigFilePath')/$(prop 'applicationConfigFileName') $(prop 'configurationFileFolder')/$(prop 'applicationConfigfileBackup')/
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App Config File backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App Config File backup completed."

#taking the Dataload service config backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload configfile backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
mkdir $(prop 'configurationFileFolder')/$(prop 'dataloadConfigFileBackup')
cp -r $(prop 'applicationBackupFolder')/$current_time/$(prop 'dataloadConfigFilePath')/$(prop 'dataloadConfigFileName') $(prop 'configurationFileFolder')/$(prop 'dataloadConfigFileBackup')/
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload configfile backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log

#taking the RuleEngine Service configfile backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine configfile backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine configfile backup started."
mkdir $(prop 'configurationFileFolder')/$(prop 'ruleEngineConfigFileBackup')
cp -r $(prop 'applicationBackupFolder')/$current_time/$(prop 'ruleEngineConfigFilepath')/$(prop 'ruleengineConfigFileName') $(prop 'configurationFileFolder')/$(prop 'ruleEngineConfigFileBackup')/
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine configfile backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine configfile backup completed."

#taking the ExportAPI Service configfile backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI configfile backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI configfile backup started."
mkdir $(prop 'configurationFileFolder')/$(prop 'exportAPIconfigfileBackup') 
cp -r $(prop 'applicationBackupFolder')/$current_time/$(prop 'exportAPIConfigFilepath')/$(prop 'exportAPIConfigFileName') $(prop 'configurationFileFolder')/$(prop 'exportAPIconfigfileBackup')/
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI configfile backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI configfile backup completed."
echo "*********Config File Backup Completed*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*********Config File Backup Completed*************"

echo ""

#Neo4j Plugin Replacing in Container

echo "*************Neo4j Plugin Replacing Started**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*************Neo4j Plugin Replacing Started**************"
sshpass -p $(prop 'serverpassword') ssh $(prop 'UserName')@$(prop 'IPAddress') "mkdir $(prop 'DBserver_releasepath')"
Pluginfile=`ls $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jPluginPath') | wc -l`
if [ $Pluginfile > 0 ]
then
sshpass -p $(prop 'serverpassword') scp $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jPluginPath') $(prop 'UserName')@$(prop 'IPAddress'):$(prop 'DBserver_releasepath')
sshpass -p $(prop 'serverpassword') ssh $(prop 'UserName')@$(prop 'IPAddress') "docker cp $(prop 'DBserver_releasepath')/$(prop 'jarfile') $(prop 'neo4jDockerContainerName'):$(prop 'neo4jContainerPluginPath')"
else
echo 'file not found in Release Folder' >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
fi
echo "*************Neo4j Plugin Replacing Completed**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*************Neo4j Plugin Replacing Completed**************"

#Neo4j Scripts update
echo "*************Release Process Started**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*************Release Process Started**************"
echo ""
echo "*******Database Release Scripts Started***********" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*******Database Release Scripts Started***********"

echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j script execution started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j script execution started."
sed -i -e "s/<NFLOWS_NEO4J_DB_CONTAINER_NAME>/$(prop 'neo4jDockerContainerName')/g" $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jScriptPath')/$(prop 'neo4jscriptfile')
sed -i -e "s/<NEO4J_DB_USER_NAME>/$(prop 'neo4jContainerUsername')/g" $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jScriptPath')/$(prop 'neo4jscriptfile')
sed -i -e "s/<NEO4J_DB_PASSWORD>/$(prop 'neo4jContainerPassword')/g" $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jScriptPath')/$(prop 'neo4jscriptfile')
sed -i -e "s/<NEO4J_DB_NAME>/$(prop 'neo4jDBname')/g" $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jScriptPath')/$(prop 'neo4jscriptfile')
sshpass -p $(prop 'serverpassword') scp -r $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jScriptPath') $(prop 'UserName')@$(prop 'IPAddress'):$(prop 'DBserver_releasepath')
sshpass -p $(prop 'serverpassword') ssh $(prop 'UserName')@$(prop 'IPAddress') "cd $(prop 'DBserver_releasepath')/$(prop 'neo4j_folder');bash $(prop 'neo4j_scriptname')"
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j script execution completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j script execution completed."
echo "*******Database Release Scripts Completed*********" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*******Database Release Scripts Completed*********"

echo ""


#WAR File replacement in the container
echo "**********Application Release Started*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Application Release Started*************"

#Application Container WAR File Replacement
ApplicationWarFile=`ls  $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'applicationRelease') | wc -l`
if [ $ApplicationWarFile -gt 0 ] 
then
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Application WAR file deployment started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Application WAR file deployment started."
docker cp $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'applicationRelease') $(prop 'applicationDockerContainerName'):$(prop 'applicationContainerPath')
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Application WAR file deployment completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Application WAR file deployment completed."
else
echo $current_time "Application WAR file is not available" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $current_time "Application WAR file is not available"
fi


#Dataload Engine Container WAR File Replacement
DataloadWarFile=`ls $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'dataloadRelease') | wc -l`
if [ $DataloadWarFile -gt 0 ]
then
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Dataload WAR file replacement started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Dataload WAR file replacement started."
docker cp $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'dataloadRelease') $(prop 'dataloadDockerContainerName'):$(prop 'dataloadContainerPath')
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Dataload WAR file replacement started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows Dataload WAR file replacement started."
else
echo $current_time "Dataload WAR file is not available" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $current_time "Dataload WAR file is not available"
fi


#Rule Engine Container WAR File Replacement
RuleEngineWarFile=`ls $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'ruleEngineRelease') | wc -l`
if [ $RuleEngineWarFile -gt 0 ]
then
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows RuleEngine WAR file replacement started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows RuleEngine WAR file replacement started."
docker cp $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'ruleEngineRelease') $(prop 'ruleEngineDockerContainerName'):$(prop 'ruleEngineContainerPath')
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows RuleEngine WAR file replacement completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows RuleEngine WAR file replacement completed."
else
echo $current_time "RuleEngine WAR file is not available" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $current_time "RuleEngine WAR file is not available"
fi


#ExportAPI Container WAR File Replacement
ExportAPIWarFile=`ls $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'exportAPIRelease') | wc -l`
if [ $ExportAPIWarFile -gt 0 ]
then
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows ExportAPI WAR file replacement started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows ExportAPI WAR file replacement started."
docker cp $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'exportAPIRelease') $(prop 'exportAPIDockerContainerName'):$(prop 'exportAPIContainerPath')
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows ExportAPI WAR file replacement completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows ExportAPI WAR file replacement completed."
else
echo $current_time "ExportAPI WAR file is not available" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $current_time "ExportAPI WAR file is not available"
fi

echo "**********Application Release completed*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Application Release completed*************"

echo ""


#update the config file from previous backup version
echo "**********Update Config File Started**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Update Config File Started**************"
#Application container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update started."
docker cp $(prop 'applicationBackupFolder')/$current_time/$(prop 'applicationConfigFilePath')/$(prop 'applicationConfigFileName') $(prop 'applicationDockerContainerName'):$(prop 'applicationContainerPath')/$(prop 'applicationname')/$(prop 'WEBINFclassespath')/$(prop 'applicationConfigFileName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update completed."

#Dataload container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update Started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update Started."
docker cp $(prop 'applicationBackupFolder')/$current_time/$(prop 'dataloadConfigFilePath')/$(prop 'dataloadConfigFileName') $(prop 'dataloadDockerContainerName'):$(prop 'dataloadContainerPath')/$(prop 'dataLoadEngineName')/$(prop 'WEBINFclassespath')/$(prop 'dataloadConfigFileName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update completed."

#RuleEngine container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine container update started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine container update started."
docker cp $(prop 'applicationBackupFolder')/$current_time/$(prop 'ruleEngineConfigFilepath')/$(prop 'ruleengineConfigFileName') $(prop 'ruleEngineDockerContainerName'):$(prop 'ruleEngineContainerPath')/$(prop 'ruleEngineName')/$(prop 'WEBINFclassespath')/$(prop 'ruleengineConfigFileName')
echo $(date "+%Y-%m-%d %H:%M:%S") "-RuleEngine container update completed" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "-RuleEngine container update completed"

#ExportAPI container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI container update started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI container update started."
docker cp $(prop 'applicationBackupFolder')/$current_time/$(prop 'exportAPIConfigFilepath')/$(prop 'exportAPIConfigFileName') $(prop 'exportAPIDockerContainerName'):$(prop 'exportAPIContainerPath')/$(prop 'exportAPIName')$(prop 'WEBINFclassespath')/$(prop 'exportAPIConfigFileName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI container update completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI container update completed."
echo "**********Update Config File Completed*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Update Config File Completed*************"

echo ""

# Restarting all Docker containers.
echo "**********Docker Containers Restart Started*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Docker Containers Restart Started*************"

echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j Docker Container Restart started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j Docker Container Restart started."
sshpass -p $(prop 'serverpassword') ssh $(prop 'UserName')@$(prop 'IPAddress') "docker container restart $(prop 'neo4jDockerContainerName')"
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j Docker Container Restart completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j Docker Container Restart completed."

echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Docker Container Restart started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Docker Container Restart started."
docker container restart $(prop 'applicationDockerContainerName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Docker Container Restart completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Docker Container Restart completed."

echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload Docker Container Restart started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload Docker Container Restart started."
docker container restart $(prop 'dataloadDockerContainerName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload Docker Container Restart completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload Docker Container Restart completed."

echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine Docker Container Restart started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine Docker Container Restart started."
docker container restart $(prop 'ruleEngineDockerContainerName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine Docker Container Restart completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine Docker Container Restart completed."

echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI Docker Container Restart started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI Docker Container Restart started."
docker container restart $(prop 'exportAPIDockerContainerName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI Docker Container Restart completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI Docker Container Restart completed."
echo "**********Docker Containers Restart Completed*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Docker Containers Restart Completed*************"

echo ""

#Checking the status of containers
#1=UP 0=Exited
 
echo "**********checking the status of containers***************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********checking the status of containers***************"
echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of Neo4j Container" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of Neo4j Container"
sshpass -p $(prop 'serverpassword') ssh $(prop 'UserName')@$(prop 'IPAddress') "docker ps | grep $(prop 'neo4jDockerContainerName') | grep "Up" | wc -l"

echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of Application Container" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of Application Container"
docker ps | grep $(prop 'applicationDockerContainerName') | grep "Up" | wc -l

echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of Dataload Container" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of Dataload Container"
docker ps | grep $(prop 'dataloadDockerContainerName') | grep "Up" | wc -l

echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of RuleEngine Container" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of RuleEngine Container"
docker ps | grep $(prop 'ruleEngineDockerContainerName') | grep "Up" | wc -l

echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of ExportAPI Container" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Checking the status of ExportAPI Container"
docker ps | grep $(prop 'exportAPIDockerContainerName') | grep "Up" | wc -l