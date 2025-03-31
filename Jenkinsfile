pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "jagadesh999/simple-webapp:latest"
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                sh 'mvn sonar:sonar -Dsonar.host.url=http://<Server3_IP>:9000 -Dsonar.login=admin -Dsonar.password=admin'
            }
        }
        stage('Push to Nexus') {
            steps {
                sh 'mvn deploy -DaltDeploymentRepository=nexus::default::http://<Server2_IP>:8081/repository/maven-releases/'
            }
        }
        stage('Build & Push Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
                sh 'docker login -u jagadesh999 -p <your_password>'
                sh 'docker push $DOCKER_IMAGE'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s-deployment.yaml'
            }
        }
    }
}

