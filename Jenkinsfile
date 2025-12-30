pipeline {
    agent any

    environment {
        REGISTRY = "harbor.buildplatform.net"
        PROJECT  = "library"
        IMAGE    = "todo-api"
        TAG      = "${env.BUILD_NUMBER}"
        PYTHON_VERSION = "3"
    }

    stages {
        stage('🚀 Checkout & Metadata') {
            steps {
                cleanWs() 
                script {
                    def scmVars = checkout scm

                    repoUrl = scmVars.GIT_URL.replace("https://", "")

                    env.GIT_COMMIT_SHORT = scmVars.GIT_COMMIT.take(7)
                    env.GIT_BRANCH_NAME = scmVars.GIT_BRANCH.replaceAll('origin/', '')
                    echo "Building Branch: ${env.GIT_BRANCH_NAME} at Commit: ${env.GIT_COMMIT_SHORT}"
                }
            }
        }

        stage('🚀 Environment Setup') {
            steps {
                echo 'Creating Virtual Environment and Installing Dependencies...'
                sh """
                    python${PYTHON_VERSION} -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                """
            }
        }

        stage('🛡️ Quality & Security') {
            parallel {
                stage('Lint & Static Analysis') {
                    steps {
                        sh """
                        python${PYTHON_VERSION} -m venv venv
                        . venv/bin/activate
                        pip install ruff bandit safety
                        ruff check .
                        bandit -r src/
                        safety check -r requirements.txt
                        """
                    }
                }
                // stage('🧪 Unit Tests') {
                //     steps {
                //         sh """
                //         . venv/bin/activate
                //         pip install pytest pytest-cov -r requirements.txt
                //         pytest --junitxml=results.xml --cov=src --cov-report=xml
                //         """
                //         junit 'results.xml'
                //     }
                // }
            }
        }

        stage('🏗️ Build Image') {
            steps {
                // Use double tagging: Build number for Jenkins, Hash for Git traceability
                sh "docker build -t ${REGISTRY}/${PROJECT}/${IMAGE}:${GIT_COMMIT_SHORT}-${TAG} ."
            }
        }

        stage('🔍 Image Audit') {
            steps {
                // Fail build if Trivy finds Critical/High vulnerabilities
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${REGISTRY}/${PROJECT}/${IMAGE}:${GIT_COMMIT_SHORT}-${TAG}"
            }
        }

        stage('📦 Push to Harbor') {
            steps {
                script {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'harbor-credentials', 
                                                        usernameVariable: 'HARBOR_USER', 
                                                        passwordVariable: 'HARBOR_PASS')]) {
                            sh """
                                echo "${HARBOR_PASS}" | docker login ${REGISTRY} -u "${HARBOR_USER}" --password-stdin
                                docker push ${REGISTRY}/${PROJECT}/${IMAGE}:${GIT_COMMIT_SHORT}-${TAG}
                                docker push ${REGISTRY}/${PROJECT}/${IMAGE}:latest
                                docker logout ${REGISTRY}
                            """
                        }
                    }
                }
            }
        }
        
        stage('🏷️ Git Tag') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-app', 
                                                    usernameVariable: 'GIT_USER', 
                                                    passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            # 1. Setup identity
                            git config user.email "jenkins@buildplatform.net"
                            git config user.name "Jenkins CI"

                            # 2. Create the tag locally
                            git tag -a "prod-v${TAG}" -m "Release commit ${GIT_COMMIT_SHORT}"

                            # 3. Handle the remote URL. 
                            repoUrl = scmVars.GIT_URL.replace("https://", "")

                            # 4. Push using the token for authentication
                            git push https://${GIT_USER}:${GIT_TOKEN}@\${repoUrl} "prod-v${TAG}"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            sh 'rm -rf venv' // Always clean up the local python environment
            sh "docker rmi ${REGISTRY}/${PROJECT}/${IMAGE}:${GIT_COMMIT_SHORT}-${TAG} || true"
            deleteDir()
        }
        success {
            echo 'Build and Deployment Successful!'
        }
        failure {
            echo 'Pipeline failed. Alerting Engineering team...'
        }
    }
}