pipeline {
    agent { label 'Terraform' }

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
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                ]) {
                    dir("${TF_DIR}") {
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                            terraform output -raw public_ip > public_ip.txt
                        '''
                    }
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    def publicIp = sh(script: "cat ${TF_DIR}/public_ip.txt", returnStdout: true).trim()
                    writeFile file: "${ANSIBLE_DIR}/inventory", text: """[webservers]
${publicIp} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/LinuxKeyPair.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
"""
                    sh "cat ${ANSIBLE_DIR}/inventory"
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
        success {
            echo '✅ Terraform & Ansible pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed! Check Jenkins logs for details.'
        }
    }
}
