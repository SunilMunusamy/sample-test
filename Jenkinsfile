node{
     
    stage('SCM Checkout'){
        git url: 'https://github.com/SunilMunusamy/sample-test.git',branch: 'dev'
    }
    
    stage(" Maven Clean Package"){
      def mavenHome =  tool name: "Maven-3.5.6", type: "maven"
      def mavenCMD = "${mavenHome}/bin/mvn"
      sh "${mavenCMD} clean package"
      
    } 
    
    
    stage('Build Docker Image'){
        sh 'docker build -t sunilsk/java-web-app .'
    }
    
   stage('Docker Image Push'){
   withCredentials([usernamePassword(credentialsId: 'Docker_Hub_Pwd',  usernameVariable: 'USERNAME', passwordVariable: 'Docker_Hub_Pwd')]) {
   sh "docker login -u ${USERNAME} -p ${Docker_Hub_Pwd}"
   sh 'docker push sunilsk/java-web-app'
   }
   }
     
      stage('Run Docker Image In Dev Server'){
        
        def dockerRun = 'docker run -d -p 8080:8080 --name java-web-app sunilsk/java-web-app'
         
         sshagent(['docker_ssh_password']) {
          sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.4.15 docker stop java-web-app || true'
          sh 'ssh  ubuntu@172.31.4.15 docker rm java-web-app || true'
          sh 'ssh  ubuntu@172.31.4.15 docker rmi -f  $(docker images -q) || true'
          sh "ssh  ubuntu@172.31.4.15 ${dockerRun}"
       }
       
    }
     
     
}
