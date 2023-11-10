pipeline {
    agent {label 'awsDeploy'}
    environment{
        DOCKERHUB_CREDENTIALS = credentials('aubreyz-dockerhub')
        }
    stages{
    stage('Change Directory'){
        steps{
            sh 'cd backend'
        }
    }
    stage('Build'){
        steps {
            sh 'docker build -t aubreyz/backend .'
        }
    }
    stage('Login') {
        steps {
          sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
        }
    }
    stage('Push') {
        steps {
            sh 'docker push aubreyz/backend'
        }
    }

    stage('Init') {
        agent {label 'awsDeploy2'}
        steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform init' 
                            }
         }
        }
    }

    stage('Plan') {
        agent {label 'awsDeploy2'}
        steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"' 
                            }
         }
        }
    }

      stage('Apply') {
        agent {label 'awsDeploy2'}
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform apply plan.tfplan' 
                            }
         }
        }
    }

}
}
