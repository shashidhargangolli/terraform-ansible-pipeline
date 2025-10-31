 pipeline {
    agent { label 'Terraform' }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION     = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/shashidhargangolli/terraform-ansible-pipeline.git'
            }
        }

        stage('Terraform Init & Apply') {
            dir('terraform') {
                steps {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                        terraform output -raw public_ip > public_ip.txt
                    '''
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    // Read Terraform output
                    def publicIp = readFile('terraform/public_ip.txt').trim()
                    echo "✅ Generated public IP: ${publicIp}"

                    // Write proper multiline inventory file
                    writeFile(
                        file: 'ansible/inventory',
                        text: """[webservers]
${publicIp} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/LinuxKeyPair.pem
"""
                    )

                    // Display generated inventory for debug
                    sh 'cat ansible/inventory'
                }
            }
        }

        stage('Run Ansible Playbook') {
            dir('ansible') {
                steps {
                    sh '''
                        echo "✅ Using inventory file:"
                        cat inventory
                        ansible-playbook -i inventory playbook.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check the logs for errors.'
        }
    }
}
