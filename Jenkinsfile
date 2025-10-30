pipeline {
    agent { label 'Terraform' }  // your agent label here

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION     = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/shashidhargangolli/terraform-ansible-pipeline.git'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Run Ansible') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory.j2 playbook.yml'
                }
            }
        }
    }
}
