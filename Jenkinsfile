pipeline {
    agent any
    
    stages {
    
        stage ('Terraform Init') {
            steps {
                dir('/terraform_project/modules/slave/') {
                    sh 'terraform init'
                }
            }
        }
     
        stage ('Terraform Apply') {
            steps {
                dir('/terraform_project/modules/slave/') {
                    sh 'terraform apply --auto-approve'
                }
            }
        }
    }
}