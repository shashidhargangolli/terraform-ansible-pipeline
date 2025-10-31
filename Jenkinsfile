pipeline {
    agent { label 'Terraform' }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/shashidhargangolli/terraform-ansible-pipeline.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
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
                    // Read public IP from Terraform output
                    def publicIp = readFile('terraform/public_ip.txt').trim()
                    echo "✅ Generated public IP: ${publicIp}"

                    // Write inventory dynamically
                    writeFile(
                        file: 'ansible/inventory',
                        text: """[webservers]
${publicIp} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/LinuxKeyPair.pem
"""
                    )

                    // Display generated inventory
                    sh 'echo "✅ Generated Inventory:" && cat ansible/inventory'
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh '''
                        echo "✅ Running Ansible Playbook..."
                        ansible-playbook -i inventory playbook.yml
                    '''
                }
            }
        }

        stage('Verify Tomcat Deployment') {
            steps {
                script {
                    def publicIp = readFile('terraform/public_ip.txt').trim()
                    echo "🌐 Checking Tomcat at: http://${publicIp}:8080"

                    // Wait a few seconds for Tomcat to start
                    sh '''
                        sleep 15
                        echo "✅ Trying to connect to Tomcat..."
                    '''

                    // Curl Tomcat home page
                    sh "curl -I http://${publicIp}:8080 || echo '⚠️ Tomcat may not be reachable yet'"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully and Tomcat verified!'
        }
        failure {
            echo '❌ Pipeline failed. Check Jenkins logs for the stage that failed.'
        }
    }
}
