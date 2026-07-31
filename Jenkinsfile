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
                    // Jenkins is on Windows, so we use 'bat' instead of 'sh'.
                    // We run our build commands inside WSL so they use Minikube's Docker daemon.
                    bat '''
                    wsl -- bash -c "eval \\$(minikube -p minikube docker-env) && docker build -t campuskart-backend:latest ./backend && docker build -t campuskart-frontend:latest ./public-view"
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                bat '''
                wsl -- kubectl apply -f k8s/mongodb.yaml
                wsl -- kubectl apply -f k8s/backend.yaml
                wsl -- kubectl apply -f k8s/frontend.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                bat '''
                wsl -- kubectl get pods
                wsl -- kubectl get svc
                '''
            }
        }
    }
}
