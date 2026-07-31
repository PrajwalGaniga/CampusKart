pipeline {
    agent any

    environment {
        // Assume Docker and kubectl are accessible.
        // If Jenkins is on Windows but you want to build in WSL, we prefix commands with `wsl` or run natively if Jenkins is in WSL.
        // For a native Linux Jenkins or Jenkins-in-Docker with host Docker socket, the below commands work normally.
        BACKEND_IMAGE = "campuskart-backend:latest"
        FRONTEND_IMAGE = "campuskart-frontend:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                // Jenkins handles the checkout from SCM automatically if configured in the pipeline job.
                // However, we explicitly check it out here for clarity.
                checkout scm
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    // In Minikube, to make images available locally without a registry, we point docker-cli to Minikube's docker daemon.
                    // If Jenkins is running on WSL, this will use the minikube docker-env.
                    sh '''
                    eval $(minikube docker-env)
                    docker build -t $BACKEND_IMAGE ./backend
                    docker build -t $FRONTEND_IMAGE ./public-view
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl apply -f k8s/mongodb.yaml
                kubectl apply -f k8s/backend.yaml
                kubectl apply -f k8s/frontend.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                kubectl get pods
                kubectl get svc
                '''
            }
        }
    }
}
