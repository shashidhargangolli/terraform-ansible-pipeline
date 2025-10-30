pipeline {
    agent { label 'Terraform' }  // 👈 Runs on the Jenkins agent labeled "Terraform"

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
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
                    writeFile file: "${ANSIBLE_DIR}/inventory", text: "[webservers]\\n${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/LinuxKeyPair.pem\\n"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        ansible-playbook -i inventory playbook.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Terraform + Ansible pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline failed! Check Jenkins logs for details."
        }
    }
}
