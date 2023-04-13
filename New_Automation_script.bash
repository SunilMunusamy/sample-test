#!/bin/bash

file=$1

function prop {
    grep -w "${1}" ${file} | cut -d'=' -f2
}

version=$(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'oldVersionDetails')

function ver {
    grep -w "${1}" ${version} | cut -d'=' -f2
}

#Append date stamp to file
file_name=graph.db-backup
current_time=$(date "+%Y%m%d-%H%M%S")
new_fileName=$current_time.$file_name

ssh $(prop 'UserName')@$(prop 'IPAddress') "cat version.cypher| docker exec -i $(prop 'neo4jDockerContainerName') cypher-shell -u $(prop 'neo4jContainerUsername') -p $(prop 'neo4jContainerPassword') -d $(prop 'neo4jDBname') >> version.txt"
scp -r $(prop 'UserName')@$(prop 'IPAddress'):version.txt $(prop 'Deploymentsscript_path')
ssh $(prop 'UserName')@$(prop 'IPAddress') "rm -rf version.txt"
sed -i -e 's/\"//g' version.txt
sed -i -e 's/version/ /g' version.txt
sed -i $'s/\r$//' $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'oldVersionDetails')
a="$(cat version.txt)"
b="$(ver 'PREVIOUS_BUILD_NUMBER')"
if [ $a = $b ]
then

#taking the backup of Neo4j
echo "*************Database Backup Started**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*************Database Backup Started**************"
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j backup started."
ssh $(prop 'UserName')@$(prop 'IPAddress') "docker exec $(prop 'neo4jDockerContainerName') mkdir -m 777 $(prop 'DBbackup_FolderName')"
ssh $(prop 'UserName')@$(prop 'IPAddress') "docker exec $(prop 'neo4jDockerContainerName') neo4j-admin backup --database=nflows --backup-dir=$(prop 'DBbackup_FolderName')"
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
mkdir -p -m 777 $(prop 'applicationBackupFolder')/$(prop 'previousversionname')
mkdir -p -m 777 $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_Appfoldername')
docker cp $(prop 'applicationDockerContainerName'):$(prop 'applicationContainerPath')/$(prop 'applicationname') $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_Appfoldername')
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- nFlows App backup completed."

#taking the Dataload service backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup started."
mkdir -p -m 777 $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_DataLoadfoldername')
docker cp $(prop 'dataloadDockerContainerName'):$(prop 'dataloadContainerPath')/$(prop 'dataLoadEngineName') $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_DataLoadfoldername')
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload service backup completed."

#taking the RuleEngine Service backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup started."
mkdir -p -m 777 $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_RuleEnginefoldername')
docker cp $(prop 'ruleEngineDockerContainerName'):$(prop 'ruleEngineContainerPath')/$(prop 'ruleEngineName') $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_RuleEnginefoldername')
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine service backup completed."

#taking the nFlowsExportAPI Service backup
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup started."
mkdir -p -m 777 $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_ExportAPIfoldername')
docker cp $(prop 'exportAPIDockerContainerName'):$(prop 'exportAPIContainerPath')/$(prop 'exportAPIName') $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_ExportAPIfoldername')
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI service backup completed."
echo "**********Application Backup Completed************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Application Backup Completed************"

echo ""


#Neo4j Plugin Replacing in Container

echo "*************Neo4j Plugin Replacing Started**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "*************Neo4j Plugin Replacing Started**************"
ssh $(prop 'UserName')@$(prop 'IPAddress') "mkdir -p -m 777 $(prop 'DBserver_releasepath')/$(prop 'DBreleaseFolderName')"
Pluginfile=`ls $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jPluginPath') | wc -l`
if [ $Pluginfile -gt 0 ]
then
scp -r $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jPluginPath') $(prop 'UserName')@$(prop 'IPAddress'):$(prop 'DBserver_releasepath')/$(prop 'DBreleaseFolderName')
ssh $(prop 'UserName')@$(prop 'IPAddress') "docker cp $(prop 'DBserver_releasepath')/$(prop 'DBreleaseFolderName')/$(prop 'jarfile') $(prop 'neo4jDockerContainerName'):$(prop 'neo4jContainerPluginPath')"
else
echo 'file not found in Release Folder' >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo 'file not found in Release Folder'
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
scp -r $(prop 'releaseFolderPath')$(prop 'nFlowsReleaseVersion')/$(prop 'neo4jScriptPath') $(prop 'UserName')@$(prop 'IPAddress'):$(prop 'DBserver_releasepath')/$(prop 'DBreleaseFolderName')
ssh $(prop 'UserName')@$(prop 'IPAddress') "cd $(prop 'DBserver_releasepath')/$(prop 'DBreleaseFolderName')/$(prop 'neo4j_folder');bash $(prop 'neo4j_scriptname')"
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

# Restarting all Docker containers.
echo "**********Docker Containers Restart Started*************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Docker Containers Restart Started*************"

echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j Docker Container Restart started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Neo4j Docker Container Restart started."
ssh $(prop 'UserName')@$(prop 'IPAddress') "docker container restart $(prop 'neo4jDockerContainerName')"
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


#update the config file from previous backup version
echo "**********Update Config File Started**************" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo "**********Update Config File Started**************"
#Application container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update started."
docker cp $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_Appfoldername')/$(prop 'applicationConfigFilePath')/$(prop 'applicationConfigFileName') $(prop 'applicationDockerContainerName'):$(prop 'applicationContainerPath')/$(prop 'applicationname')/$(prop 'WEBINFclassespath')/$(prop 'applicationConfigFileName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Application Container update completed."

#Dataload container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update Started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update Started."
docker cp $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_DataLoadfoldername')/$(prop 'dataloadConfigFilePath')/$(prop 'dataloadConfigFileName') $(prop 'dataloadDockerContainerName'):$(prop 'dataloadContainerPath')/$(prop 'dataLoadEngineName')/$(prop 'WEBINFclassespath')/$(prop 'dataloadConfigFileName')
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update completed." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- Dataload container update completed."

#RuleEngine container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine container update started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- RuleEngine container update started."
docker cp $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_RuleEnginefoldername')/$(prop 'ruleEngineConfigFilepath')/$(prop 'ruleengineConfigFileName') $(prop 'ruleEngineDockerContainerName'):$(prop 'ruleEngineContainerPath')/$(prop 'ruleEngineName')/$(prop 'WEBINFclassespath')/$(prop 'ruleengineConfigFileName')
echo $(date "+%Y-%m-%d %H:%M:%S") "-RuleEngine container update completed" >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "-RuleEngine container update completed"

#ExportAPI container update from previous version
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI container update started." >> nFlowsReleaselog_before_$(prop 'nFlowsReleaseVersion')_$current_time.log
echo $(date "+%Y-%m-%d %H:%M:%S") "- ExportAPI container update started."
docker cp $(prop 'applicationBackupFolder')/$(prop 'previousversionname')/$(prop 'backup_ExportAPIfoldername')/$(prop 'exportAPIConfigFilepath')/$(prop 'exportAPIConfigFileName') $(prop 'exportAPIDockerContainerName'):$(prop 'exportAPIContainerPath')/$(prop 'exportAPIName')$(prop 'WEBINFclassespath')/$(prop 'exportAPIConfigFileName')
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
ssh $(prop 'UserName')@$(prop 'IPAddress') "docker container restart $(prop 'neo4jDockerContainerName')"
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
ssh $(prop 'UserName')@$(prop 'IPAddress') "docker ps | grep $(prop 'neo4jDockerContainerName') | grep "Up" | wc -l"

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

else
echo "Version is not matching"
fi

















































#########Properties

############# Neo4j SERVER DETAILS ################ 

#Neo4j DataBase Container Name
neo4jDockerContainerName=nFlowsNeo4jService

############ APPLICATION BACKUP DIRECTORY CREATION ###############
#Application Backup Directory Creation
applicationBackupFolder=/home/redhat.secure/applicationbackup


########### APPLICATION CONTAINER DETAILS ##############
#Application Container Name
applicationDockerContainerName=nFlowsAppService
#Application Container Webapps Path
applicationContainerPath=/usr/local/tomcat/webapps
#Application Name
applicationname=nFlows


############ DATALOAD ENGINE DETAILS #################
#DataLoadEngine Container Name
dataloadDockerContainerName=nFlowsR1DataLoadEngine
#DataLoadEngine Container Webapps Path
dataloadContainerPath=/usr/local/tomcat/webapps
#DataLoadEngine Name
dataLoadEngineName=nFlowsDataEngine


############ RULEENGINE CONTAINER DETAILS ############
#RuleEngine Container Name
ruleEngineDockerContainerName=nFlowsRuleEngine
#RuleEngine Container Webapps Path
ruleEngineContainerPath=/usr/local/tomcat/webapps
#RuleEngine Name
ruleEngineName=nFlowsRuleEngine


############ EXPORTAPI CONTAINER DETAILS ###############
#ExportAPI Container Name
exportAPIDockerContainerName=nFlowsExportAPI
#ExportAPI Container Webapps Path
exportAPIContainerPath=/usr/local/tomcat/webapps
#ExportAPI Name
exportAPIName=nFlowsExportAPI


########### CONFIG FILE DIRECTORY ################
#Directory Creation for Config File 
configurationFileFolder=/home/redhat.secure/configurationfile


########## APPLICATION CONFIGFILE DETAILS ###########
#Application Configfile Path
applicationConfigFilePath=nFlows/WEB-INF/classes
#Application ConfigFile Name
applicationConfigFileName=AppConfig.Properties 
#Application Configfile Backup Folder
applicationConfigfileBackup=ApplicationconfigBackup


########### DATALOAD CONFIGFILE DETAILS ############
#DataloadEngine Configfile  Path
dataloadConfigFilePath=nFlowsDataEngine/WEB-INF/classes
#DataloadEngine ConfigFile Name
dataloadConfigFileName=application.properties
#DataloadEngine Configfile Backup Folder
dataloadConfigFileBackup=DataloadConfigBackup


########### RULEENGINE CONFIGFILE DETAILS ###########
#RuleEngine ConfigFile Path
ruleEngineConfigFilepath=nFlowsRuleEngine/WEB-INF/classes
#RuleEngine ConfigFile Name
ruleengineConfigFileName=application.properties
#RuleEngine configfile Backup Folder
ruleEngineConfigFileBackup=RuleEngineConfigBackup


########### EXPORTAPI CONFIGFILE DETAILS ###########
#ExportAPI ConfigFile path
exportAPIConfigFilepath=nFlowsExportAPI/WEB-INF/classes
#ExportAPI ConfigFile Name
exportAPIConfigFileName=application.properties
#ExportAPI configfile Backup Folder
exportAPIconfigfileBackup=ExportAPIconfigBackup


########## CONTAINER WEB-INF PATH ###############
#WEB-INF/classes
WEBINFclassespath=/WEB-INF/classes


######### NEO4J CONTAINER DB SERVER USERNAME&PASSWORD ########## 
#Neo4jDB Container Details
neo4jContainerUsername=neo4j
neo4jContainerPassword=AdminNeo4j
neo4jDBname=nflows


########## RELEASE FOLDER DETAILS ##########
#Cypherscript Home Path
releaseFolderPath=/home/redhat.secure/Release/nFlowsRelease
#Cypherscript Neo4j Path
neo4jScriptPath=Scripts/Neo4j
#Neo4j Scriptfile
neo4jscriptfile=Neo4jScripts.sh
#nFlowsRelease Version
nFlowsReleaseVersion=V4.0.224

########## NEO4J CONTAINER PLUGIN PATH ###########
#Neo4j Plugin Path
neo4jPluginPath=Neo4jPlugin/*.jar


###########RELEASE PATH FOR WAR FILE REPLACEMENT#############
#War File Replacement In The Application Container
applicationRelease=Application/nFlows.war
#War File Replacement In The Dataload Container
dataloadRelease=nFlowsDataEngine/nFlowsDataEngine.war
#War File Replacement In The RuleEngine Container
ruleEngineRelease=nFlowsRuleEngine/nFlowsRuleEngine.war
#War File Replacement In The ExportAPI Container
exportAPIRelease=nFlowsExportAPI/nFlowsExportAPI.war



############DATABASE SERVER DETAILS############

#########DATABASE SERVER USERNAME&PASSWORD&IP############ 
#DBserver Login Password
serverpassword=StdAcce55
#DB Server Username&Password
UserName=superuser
IPAddress=192.168.1.19

#Neo4j Container Plugin Path
neo4jContainerPluginPath=/var/lib/neo4j/plugins
#Directory for Plugin and Scripts
DBserver_releasepath=/home/superuser/Neo4jRelease
#Folder for Scripts in DB Server
neo4j_folder=Neo4j
#Jar File Name
jarfile=*.jar
#Script Name
neo4j_scriptname=Neo4jScripts.sh





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