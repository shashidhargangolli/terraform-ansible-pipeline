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
                        terraform init
                        terraform apply -auto-approve
                        terraform output -raw public_ip > ../public_ip.txt
                    '''
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    def public_ip = sh(script: "cat public_ip.txt", returnStdout: true).trim()
                    writeFile file: "${ANSIBLE_DIR}/inventory", text: """[webservers]
${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/LinuxKeyPair.pem
"""
                    sh "cat ${ANSIBLE_DIR}/inventory"
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
            echo '✅ Terraform & Ansible pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed! Check Jenkins logs for details.'
        }
    }
}
