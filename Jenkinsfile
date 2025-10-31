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
                echo "✅ Cloning repository..."
                git branch: 'main', url: 'https://github.com/shashidhargangolli/terraform-ansible-pipeline.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        echo "✅ Initializing and Applying Terraform..."
                        terraform init -input=false
                        terraform apply -auto-approve -input=false
                        terraform output -raw public_ip > public_ip.txt
                    '''
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    def publicIp = readFile('terraform/public_ip.txt').trim()
                    echo "✅ Generated public IP: ${publicIp}"

                    writeFile file: 'ansible/inventory', text: """[webservers]
${publicIp} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/LinuxKeyPair.pem
"""

                    echo "✅ Generated Inventory File:"
                    sh 'cat ansible/inventory'
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh '''
                        echo "✅ Running Ansible Playbook..."
                        export ANSIBLE_HOST_KEY_CHECKING=False
                        ansible-playbook -i inventory playbook.yml
                    '''
                }
            }
        }

        stage('Verify Tomcat Deployment') {
            steps {
                script {
                    def publicIp = readFile('terraform/public_ip.txt').trim()
                    echo "🌐 Checking Tomcat service on ${publicIp}:8080 ..."
                    sh "curl -I http://${publicIp}:8080 || echo 'Tomcat not reachable yet.'"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully! Tomcat should now be running on port 8080.'
        }
        failure {
            echo '❌ Pipeline failed. Check Jenkins logs for errors.'
        }
    }
}
