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
        stage("Init") {
            steps { initialize() }
        }
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
//         stage('Docker Run Image Local') {
//             steps {
//                 sh 'docker run -d -it --name hello-service-container -p 8888:8888 --env JAEGER_HOST=localhost ' + dockerImage
//             }
//         }
        stage('Deliver Image To Hub') {
            steps {
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Deploy to Staging') {
            steps {
                echo "Deploy Staging Success"
            }
        }
        stage('Deploy to Production') {
            steps {
                echo "Deploy Production Success"
            }
        }
    }
}

def initialize() {
    env.MAX_ENVIRONMENT_NAME_LENGTH = 32
    setEnvironment()
}

def runSecurityTest() {
    def sonarReportDir = "target/sonar"
    def sonarqubeIP = findSonarqubeIp()
    echo "sonarqubeIP = [$sonarqubeIP]"
    sh "mvn sonar:sonar -Dsonar.host.url=http://$sonarqubeIP:9000"
    sh "ls -al $sonarReportDir"
}

def findSonarqubeIp() {
    def ip = ""
    ip = sh(returnStdout: true, script: "docker inspect --format '{{ .NetworkSettings.IPAddress }}' sonarqube").trim()
    echo "ip = [$ip]"
    return ip
}

def deployImage(environment) {
    def context = getContext(environment)
}

def getContext(environment) {
    return (env.BRANCH_NAME == 'master') ? environment : 'dev'
}

def findIp(environment) {
    def ip = ""
    return ip
}

def setEnvironment() {
    def branchName = env.BRANCH_NAME.toLowerCase()
    def environment = 'dev'
    echo "branchName = $branchName"
    if (branchName == "") {
        showEnvironmentVariables() throw "BRANCH_NAME is not an environment variable or is empty"
    }
    else if (branchName != "master") {
        if (branchName.contains("/")) {
            branchName = branchName.split("/")[1]
        }
        branchName = branchName.replace("-", "")
        branchName = branchName.take(env.MAX_ENVIRONMENT_NAME_LENGTH as Integer)
        environment += "-" + branchName
    }
    echo "Using environment: $environment"
    env.ENVIRONMENT = environment
}

def showEnvironmentVariables() {
    sh 'env | sort > env.txt'
    sh 'cat env.txt'
}