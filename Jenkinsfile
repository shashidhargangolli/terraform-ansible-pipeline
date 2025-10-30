pipeline {
    agent { label 'terraform' }

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/shashidhargangolli/terraform-ansible-pipeline.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    def public_ip = sh(script: "cat terraform/public_ip.txt", returnStdout: true).trim()
                    writeFile file: "${ANSIBLE_DIR}/inventory", text: "[webservers]\\n${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/LinuxKeyPair.pem\\n"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh 'ansible-playbook -i inventory playbook.yml'
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed! Check Jenkins logs for details."
        }
        success {
            echo "✅ Pipeline executed successfully!"
        }
    }
}
