pipeline {
    agent any

    environment {
        IMAGE_NAME = 'manjulakadari/nexvion'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    withSonarQubeEnv('sonarqube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=nexvion \
                            -Dsonar.projectName=Nexvion \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=.git/**,k8s/**,README.txt
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                sh 'trivy fs --scanners vuln,misconfig,secret .'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                          -u "$DOCKER_USER" \
                          --password-stdin

                        docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                        docker logout
                    '''
                }
            }
        }

       stage('Deploy to Kubernetes') {
           steps {
               sh '''
                 export KUBECONFIG=/var/lib/jenkins/.kube/config


                  echo "Checking Kubernetes connection..."
                  kubectl config current-context
                  kubectl get nodes

                 echo "Deploying Nexvion..."
                 kubectl apply -f k8s/namespace.yaml
                 kubectl apply -f k8s/deployment.yaml
                 kubectl apply -f k8s/service.yaml

                echo "Checking deployment status..."
                kubectl get all -n nexvion
    '''
}


}


        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl get pods -n nexvion
                    kubectl get services -n nexvion
                '''
            }
        }
    }
}
