pipeline {
    agent any

    environment {
        CONTAINER_NAME = 'campuskart-backend'
        IMAGE_NAME = 'campuskart-backend:latest'
        PORT = '8000'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('backend') {
                    echo 'Building backend Docker image...'
                    bat 'docker build -t %IMAGE_NAME% .'
                }
            }
        }

        stage('Stop and Remove Existing Container') {
            steps {
                echo 'Stopping and removing existing container if it exists...'
                bat '''
                docker stop %CONTAINER_NAME% >nul 2>&1 || exit 0
                docker rm %CONTAINER_NAME% >nul 2>&1 || exit 0
                '''
            }
        }

        stage('Run Container') {
            steps {
                echo 'Starting new container...'
                bat 'docker run -d -p %PORT%:8000 --name %CONTAINER_NAME% %IMAGE_NAME%'
            }
        }
        
        stage('Verify Health') {
            steps {
                echo 'Waiting for container to start...'
                sleep 10
                bat 'curl -f http://localhost:%PORT%/health || exit 1'
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
