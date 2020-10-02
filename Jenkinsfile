pipeline {
    environment {
        registry = 'thanhle21/hello-service'
        registryCredential = 'dockerhub'
    }
    agent {
        docker {
            image 'maven:3-alpine'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('Maven Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Maven Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Docker Build Image') {
            steps {
                sh 'docker build . -t hello-service-node:1'
            }
        }
        stage('Docker Run Image') {
            steps {
                sh 'docker run -d -it --name hello-service-container -p 8888:8888 --env JAEGER_HOST=localhost hello-service-node:1'
            }
        }
        stage('Deliver Push Image To Hub') {
            steps {
                sh 'sh ./deliver.sh'
            }
        }
    }
}