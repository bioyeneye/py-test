pipeline {
    agent any

    environment {
        REGISTRY = "harbor.buildplatform.net"
        PROJECT  = "library"
        IMAGE    = "todo-api"
        TAG      = "${BUILD_NUMBER}"
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
                          docker push ${REGISTRY}/${PROJECT}/${IMAGE}:${TAG}
                          docker tag ${REGISTRY}/${PROJECT}/${IMAGE}:${TAG} ${REGISTRY}/${PROJECT}/${IMAGE}:latest
                          docker push ${REGISTRY}/${PROJECT}/${IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker rmi ${REGISTRY}/${PROJECT}/${IMAGE}:${TAG} || true'
                sh 'docker rmi ${REGISTRY}/${PROJECT}/${IMAGE}:latest || true'
            }
        }
    }
}