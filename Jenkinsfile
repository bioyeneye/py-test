pipeline {
    agent any

    environment {
        REGISTRY = "harbor.buildplatform.net"
        PROJECT  = "library"
        IMAGE    = "todo-api"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    TAG = "${env.BUILD_NUMBER}"
                    dockerImage = docker.build("${REGISTRY}/${PROJECT}/${IMAGE}:${TAG}", ".")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'harbor-credentials',
                                                     usernameVariable: 'HARBOR_USER',
                                                     passwordVariable: 'HARBOR_PASS')]) {
                        sh """
                          echo "$HARBOR_PASS" | docker login $REGISTRY -u "$HARBOR_USER" --password-stdin
                          docker push ${REGISTRY}/${PROJECT}/${IMAGE}:${env.BUILD_NUMBER}
                          docker tag ${REGISTRY}/${PROJECT}/${IMAGE}:${env.BUILD_NUMBER} ${REGISTRY}/${PROJECT}/${IMAGE}:latest
                          docker push ${REGISTRY}/${PROJECT}/${IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker rmi ${REGISTRY}/${PROJECT}/${IMAGE}:${env.BUILD_NUMBER} || true'
                sh 'docker rmi ${REGISTRY}/${PROJECT}/${IMAGE}:latest || true'
            }
        }
    }
}