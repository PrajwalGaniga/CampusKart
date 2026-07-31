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
                checkout scm
            }
        }
        
        stage('Prepare Environment') {
            steps {
                script {
                    bat '''
                    echo "--- Checking WSL Distribution ---"
                    wsl -l -v
                    
                    echo "--- Starting Minikube (if stopped) ---"
                    wsl -- bash -c "minikube status || minikube start --driver=docker"
                    
                    echo "--- Checking Minikube & Docker Status ---"
                    wsl -- bash -c "minikube status"
                    wsl -- bash -c "docker --version"
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Split out the commands to see exactly which one fails.
                    // Note: Removed the backslash before $ which might have caused bash syntax errors!
                    bat '''
                    echo "--- Building Backend ---"
                    wsl -- bash -c "eval $(minikube docker-env) && cd backend && docker build -t campuskart-backend:latest ."
                    '''

                    bat '''
                    echo "--- Building Frontend ---"
                    wsl -- bash -c "eval $(minikube docker-env) && cd public-view && docker build -t campuskart-frontend:latest ."
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                bat '''
                echo "--- Applying K8s Manifests ---"
                wsl -- kubectl apply -f k8s/mongodb.yaml
                wsl -- kubectl apply -f k8s/backend.yaml
                wsl -- kubectl apply -f k8s/frontend.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                bat '''
                echo "--- Fetching Pods and Services ---"
                wsl -- kubectl get pods
                wsl -- kubectl get svc
                '''
            }
        }
    }
}
