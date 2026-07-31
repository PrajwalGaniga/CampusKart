def failedStage = ""

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
            post { failure { script { failedStage = 'Checkout' } } }
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
            post { failure { script { failedStage = 'Prepare Environment' } } }
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
                    wsl -- bash -c "cd public-view && minikube image build -t campuskart-frontend:latest ."
                    '''
                }
            }
            post { failure { script { failedStage = 'Build Docker Images' } } }
        }

        stage('Deploy Observability (Helm)') {
            steps {
                bat '''
                echo "--- Setting up Helm Repos ---"
                wsl -- bash -c "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true"
                wsl -- bash -c "helm repo add grafana https://grafana.github.io/helm-charts || true"
                wsl -- bash -c "helm repo update"
                
                echo "--- Deploying Prometheus & Grafana ---"
                wsl -- bash -c "helm upgrade --install prometheus prometheus-community/prometheus"
                wsl -- bash -c "helm upgrade --install grafana grafana/grafana"
                '''
            }
            post { failure { script { failedStage = 'Deploy Observability (Helm)' } } }
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
                wsl -- kubectl rollout restart deployment campuskart-frontend
                '''
            }
            post { failure { script { failedStage = 'Deploy to Kubernetes' } } }
        }

        stage('Verify Deployment') {
            steps {
                bat '''
                echo "--- Fetching Pods and Services ---"
                wsl -- kubectl get pods
                wsl -- kubectl get svc
                '''
            }
            post { failure { script { failedStage = 'Verify Deployment' } } }
        }
    }

    post {
        always {
            script {
                def buildStatus = currentBuild.result ?: 'SUCCESS'
                def statusColor = buildStatus == 'SUCCESS' ? '#4CAF50' : (buildStatus == 'FAILURE' ? '#F44336' : '#FF9800')
                def subject = "CampusKart Build ${buildStatus}: ${env.JOB_NAME} [#${env.BUILD_NUMBER}]"
                def duration = currentBuild.durationString.replace(" and counting", "")
                
                def stagesList = ['Checkout', 'Prepare Environment', 'Build Docker Images', 'Deploy Observability (Helm)', 'Deploy to Kubernetes', 'Verify Deployment']
                def stageRows = ""
                boolean hasFailed = false
                
                for (String s : stagesList) {
                    if (hasFailed) {
                        stageRows += """
                        <tr>
                            <td style="padding: 12px; border-bottom: 1px solid #eee; color: #555; font-weight: 500;">${s}</td>
                            <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right;"><span style="background-color: #f5f5f5; color: #9e9e9e; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold;">⚪ SKIPPED</span></td>
                        </tr>
                        """
                    } else if (failedStage == s) {
                        hasFailed = true
                        stageRows += """
                        <tr>
                            <td style="padding: 12px; border-bottom: 1px solid #eee; color: #333; font-weight: bold;">${s}</td>
                            <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right;"><span style="background-color: #ffebee; color: #f44336; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold;">❌ FAILED</span></td>
                        </tr>
                        """
                    } else {
                        stageRows += """
                        <tr>
                            <td style="padding: 12px; border-bottom: 1px solid #eee; color: #333; font-weight: 500;">${s}</td>
                            <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right;"><span style="background-color: #e8f5e9; color: #4caf50; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold;">✅ SUCCESS</span></td>
                        </tr>
                        """
                    }
                }

                def body = """
                    <html>
                    <body style="font-family: 'Segoe UI', Arial, sans-serif; background-color: #f0f2f5; padding: 30px; margin: 0;">
                        <div style="max-width: 650px; margin: auto; background: white; border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); overflow: hidden;">
                            <!-- Header -->
                            <div style="background-color: ${statusColor}; padding: 25px 30px; color: white;">
                                <h1 style="margin: 0; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;">CampusKart CI/CD Operations</h1>
                                <p style="margin: 8px 0 0 0; font-size: 15px; opacity: 0.9;">Automated Deployment Report</p>
                            </div>
                            
                            <!-- Body -->
                            <div style="padding: 35px 30px;">
                                <p style="font-size: 16px; color: #444; line-height: 1.6; margin-top: 0;">Hello <strong>Prajwal</strong>,</p>
                                <p style="font-size: 16px; color: #444; line-height: 1.6;">The pipeline execution for branch <strong>${env.BRANCH_NAME ?: 'main'}</strong> has concluded. Below is the detailed breakdown of the execution stages.</p>
                                
                                <!-- Meta Info Grid -->
                                <div style="display: table; width: 100%; margin: 25px 0; background-color: #f8f9fa; border-radius: 8px; padding: 15px 0;">
                                    <div style="display: table-cell; width: 33%; text-align: center; border-right: 1px solid #e0e0e0;">
                                        <span style="display: block; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;">Build Number</span>
                                        <span style="display: block; font-size: 18px; color: #212121; font-weight: bold; margin-top: 4px;">#${env.BUILD_NUMBER}</span>
                                    </div>
                                    <div style="display: table-cell; width: 33%; text-align: center; border-right: 1px solid #e0e0e0;">
                                        <span style="display: block; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;">Total Duration</span>
                                        <span style="display: block; font-size: 18px; color: #212121; font-weight: bold; margin-top: 4px;">${duration}</span>
                                    </div>
                                    <div style="display: table-cell; width: 33%; text-align: center;">
                                        <span style="display: block; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;">Final Status</span>
                                        <span style="display: block; font-size: 18px; color: ${statusColor}; font-weight: bold; margin-top: 4px;">${buildStatus}</span>
                                    </div>
                                </div>
                                
                                <!-- Stage Breakdown Table -->
                                <h3 style="color: #333; font-size: 16px; margin: 30px 0 15px 0; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;">Execution Stages</h3>
                                <table style="width: 100%; border-collapse: collapse; margin-bottom: 30px;">
                                    <tbody>
                                        ${stageRows}
                                    </tbody>
                                </table>
                                
                                <!-- Action Button -->
                                <div style="text-align: center; margin: 40px 0 10px 0;">
                                    <a href="${env.BUILD_URL}" style="background-color: #2196F3; color: white; padding: 14px 32px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 15px; display: inline-block; box-shadow: 0 4px 6px rgba(33,150,243,0.3); transition: all 0.3s ease;">View Full Logs in Jenkins</a>
                                </div>
                            </div>
                            
                            <!-- Footer -->
                            <div style="background-color: #f8f9fa; padding: 20px 30px; text-align: center; border-top: 1px solid #eeeeee;">
                                <p style="font-size: 12px; color: #9e9e9e; margin: 0;">This is a system-generated notification from CampusKart DevOps infrastructure.</p>
                                <p style="font-size: 12px; color: #9e9e9e; margin: 4px 0 0 0;">Do not reply to this email.</p>
                            </div>
                        </div>
                    </body>
                    </html>
                """

                emailext(
                    subject: subject,
                    body: body,
                    mimeType: 'text/html',
                    to: 'prajwalganiga06@gmail.com'
                )
            }
        }
    }
}
