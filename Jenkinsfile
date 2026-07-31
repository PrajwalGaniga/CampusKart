pipeline {
    agent any

    environment {
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
                    bat '''
                    echo "--- Building Backend ---"
                    wsl -- bash -c "cd backend && minikube image build -t campuskart-backend:latest ."
                    '''

                    bat '''
                    echo "--- Building Frontend ---"
                    wsl -- bash -c "cd frontend && minikube image build -t campuskart-frontend:latest ."
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
                
                echo "--- Forcing Rollout to use new images ---"
                wsl -- kubectl rollout restart deployment campuskart-backend
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
