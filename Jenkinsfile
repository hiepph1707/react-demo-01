pipeline {

    agent none
    //agent {label 'master'}
    
    environment {
        PROJECT_NAME = 'react-demo01'
        DOCKER_REGISTRY = 'asia.gcr.io/gke-lab-02'
        IMAGE_TAG = "${BRANCH_NAME}.${BUILD_ID}"
        PUBLIC_DOMAIN = 'react-demo01.hiepsharing.com'
        PORT = '3000'
        POD_LABEL = 'app: react'

        // GOOGLE CLOUD VARIABLE ENV
        GCP_PROJECT_ID = 'gke-lab-02'
        GCP_CLUSTER = 'c-gke-dev'
        GCP_ZONE = 'asia-southeast2-b'

    }

     stages {        
        stage('Build Image') {
            agent {label 'master'}
            steps { 
                script { 
                    dockerImage = docker.build DOCKER_REGISTRY + "/${PROJECT_NAME}:${IMAGE_TAG}" 
                }
            } 
        }

        stage('Push Image') {
            agent {label 'master'}
            steps {
                script {
                    docker.withRegistry( 'https://asia.gcr.io', "gcr:cre-gcr-gke-lab-02" ) { 
                        dockerImage.push() 
                    }
                }
            }
        }

        stage('Cleaning up') { 
            agent {label 'master'}
            steps { 
                sh '''
                    docker rmi ${DOCKER_REGISTRY}/${PROJECT_NAME}:${IMAGE_TAG}
                ''' 
            }
        }

        stage('Deploy to GKE') {
            agent {label 'master'}
            steps {
                sh """
                    sed -e "s|PROJECT_NAME|${PROJECT_NAME}|g; s|PORT|${PORT}|g; s|POD_LABEL|${POD_LABEL}|g; s|REGISTRY|${DOCKER_REGISTRY}|g; s|TAG|${IMAGE_TAG}|g; s|PUBLIC_DOMAIN|${PUBLIC_DOMAIN}|g" manifest.yml > manifest-new.yml
                """

                step([$class: 'KubernetesEngineBuilder', 
                    projectId: env.GCP_PROJECT_ID,
                    clusterName: env.GCP_CLUSTER,
                    zone: env.GCP_ZONE,
                    manifestPattern: 'manifest-new.yml',
                    credentialsId: 'cre-c-gke-dev',
                    verifyDeployments: false])               
            }
        }

    }
    
    // post {
    //     always {
    //         rocketSend "${env.JOB_NAME} - Build #${env.BUILD_NUMBER} [${currentBuild.currentResult}] (<${env.BUILD_URL}|Open>)"
    //     }
    // }
}
