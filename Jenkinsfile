pipeline {
    environment {
        registry = "thanhle21/hello-service"
        registryCredential = 'dockerhub'
        dockerImage = ''
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
        stage('Run Security Scan') {
            steps { runSecurityTest() }
        }
        stage('Docker Build Image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }
//         stage('Docker Run Image') {
//             steps {
//                 sh 'docker run -d -it --name hello-service-container -p 8888:8888 --env JAEGER_HOST=localhost hello-service-node:1'
//             }
//         }
        stage('Deliver Push Image To Hub') {
            steps {
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                    }
                }
            }
        }
    }
}

def runSecurityTest() {
    def sonarReportDir = "target/sonar"
    def sonarqubeIP = findSonarqubeIp()
    sh "mvn sonar:sonar -Dsonar.host.url=http://$jsonarqubeIP:9000"
    sh "ls -al $sonarReportDir"
}

def findSonarqubeIp() {
    def ip = ""
    ip = sh "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube"
    return ip
}