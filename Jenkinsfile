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
//         stage('Maven Test') {
//             steps {
//                 sh 'mvn test'
//             }
//             post {
//                 always {
//                     junit 'target/surefire-reports/*.xml'
//                 }
//             }
//         }
//         stage('Run Security Scan') {
//             steps { runSecurityTest() }
//         }
        stage('Docker Build Image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }
        stage('Deploy to Local') {
            steps { deployImage('local') }
        }
//         stage('Deploy to Dev') {
//             when { branch 'dev' }
//             steps { deployImage('dev') }
//         }
        stage('Process to Production') {
            when { branch 'release' }
            steps { proceedTo('prod') }
        }
        stage('Deploy to Production') {
            when { branch 'release' }
            steps {
                // deployImage(prod)
                echo "Deploy Production Success"
            }
        }
        stage('Deliver Image To Hub') {
            when { branch 'release'}
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

// ===================================================================
// Initialization steps
// ===================================================================

def initialize() {
    env.MAX_ENVIRONMENT_NAME_LENGTH = 32
    env.SERVICE_NAME = "hello-service"
    setEnvironment()
    showEnvironmentVariables()
}

def setEnvironment() {
    def branchName = env.BRANCH_NAME.toLowerCase()
    def environment = ''
    echo "branchName = $branchName"
    if (branchName == "") {
        showEnvironmentVariables()
        throw "BRANCH_NAME is not an environment variable or is empty"
    }
    else if (branchName != "master") {
        if (branchName.contains("/")) {
            branchName = branchName.split("/")[1]
        }
        branchName = branchName.replace("-", "")
        if (env.JIRA_PROJECT_NAME) {
            branchName = branchName.replace(env.JIRA_PROJECT_NAME, "")
        }
        branchName = branchName.take(env.MAX_ENVIRONMENT_NAME_LENGTH as Integer)
        environment = branchName
    }
    echo "Using environment: $environment"
    env.ENVIRONMENT = environment
}

def showEnvironmentVariables() {
    sh 'env | sort > env.txt'
    sh 'cat env.txt'
}

def runSecurityTest() {
    def sonarReportDir = "target/sonar"
    def sonarqubeIP = findSonarqubeIp()
    sh "mvn sonar:sonar -Dsonar.host.url=http://$sonarqubeIP:9000"
    sh "ls -al $sonarReportDir"
}

def findSonarqubeIp() {
    def ip = ""
    ip = sh(returnStdout: true, script: "docker inspect --format '{{ .NetworkSettings.IPAddress }}' sonarqube").trim()
    echo "sonarqubeIP = [$ip]"
    return ip
}

def deployImage(environment) {
    def ip = findIp(environment)
    def dockerImageNameTag = registry + ":$BUILD_NUMBER"
    def dockerContainer = env.SERVICE_NAME + "-container"
    def port = 5000
    echo "Deploy $dockerImageNameTag to env environment $environment with name $dockerContainer"
    sh "docker run -d -it --name $dockerContainer -p $port:$port -e PORT=$port -e JAEGER_HOST=$ip $dockerImageNameTag"
}

def findIp(environment) {
    def ip = ""
    if (env.BRANCH_NAME == "dev-test") {
        ip = sh(returnStdout: true, script: "docker-machine ip default")
        sh 'eval $(docker-machine env default)'
    }
    else if (env.BRANCH_NAME == "release-test") {
        ip = sh(returnStdout: true, script: "docker-machine ip prod")
        sh 'eval $(docker-machine env prod)'
    }
    else {
        ip = "localhost"
    }
    echo "environmentIP = [$ip]"
    return ip
}

def proceedTo(environment) {
    def description = "Choose 'yes' if you want to deploy to this build to " +
        "the $environment environment"
    def proceed = 'no'
    timeout(time: 4, unit: 'HOURS') {
        proceed = input message: "Do you want to deploy the changes to $environment?",
            parameters: [choice(name: "Deploy to $environment", choices: "no\nyes",
                description: description)]
        if (proceed == 'no') {
            error("User stopped pipeline execution")
        }
    }
}