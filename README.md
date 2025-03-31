# **Manual CI/CD Pipeline with Maven, Nexus, SonarQube, Jenkins, Docker & Kubernetes**

## ** Project Overview**  
This project sets up a **manual CI/CD pipeline** using:  
 **Maven** (Build)  
 **Jenkins** (CI/CD Automation)  
 **SonarQube** (Code Quality Analysis)  
 **Nexus** (Artifact Repository)  
 **Docker** (Containerization)  
 **Kubernetes** (Deployment & LoadBalancer)  

The pipeline builds a **Java Web Application**, scans it with **SonarQube**, stores artifacts in **Nexus**, creates a **Docker image**, pushes it to **Docker Hub**, and deploys it to **Kubernetes**.

---

## ** Infrastructure Setup**  
### ** Five Dedicated Servers**
| **Server**      | **Components Installed**       | **IP Address** |
|---------------|--------------------------|--------------|
| **Server 1** | Jenkins, Maven, Docker    | `<Server1_IP>` |
| **Server 2** | Nexus Repository          | `<Server2_IP>` |
| **Server 3** | SonarQube                  | `<Server3_IP>` |
| **Server 4 (Master Node)** | Kubernetes Master | `<Server4_Master_IP>` |
| **Server 5 (Worker Node)** | Kubernetes Worker Node | `<Server5_Node_IP>` |

---

## ** Step 1: Set Up Server 1 (Maven, Jenkins, Docker)**
### **1 Install Java & Maven**
```bash
sudo apt update -y
sudo apt install -y openjdk-11-jdk maven
mvn -version
```

### **2 Install Jenkins**
```bash
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
echo "deb http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins && sudo systemctl enable jenkins
```

### **3 Install Docker**
```bash
sudo apt install -y docker.io
sudo systemctl start docker && sudo systemctl enable docker
sudo usermod -aG docker jenkins
```

---

## ** Step 2: Set Up Server 2 (Nexus Repository)**
### **1 Install Nexus**
```bash
sudo apt update -y
sudo apt install -y openjdk-11-jdk
sudo useradd -m -d /opt/nexus nexus
cd /opt/nexus
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -xvf latest-unix.tar.gz
mv nexus-* nexus
chown -R nexus:nexus /opt/nexus
```

### **2️⃣ Start Nexus**  
```bash
sudo -u nexus /opt/nexus/bin/nexus start
```
Access: **http://<Server2_IP>:8081**  

---

## **📌 Step 3: Set Up Server 3 (SonarQube)**
### **1️⃣ Install SonarQube**
```bash
sudo apt update -y
sudo apt install -y openjdk-11-jdk
sudo useradd -m sonar
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.2.zip
sudo unzip sonarqube-9.9.2.zip
sudo mv sonarqube-9.9.2 sonarqube
chown -R sonar:sonar /opt/sonarqube
```

### **2 Start SonarQube**
```bash
sudo -u sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh start
```
Access: **http://<Server3_IP>:9000**  

---

## ** Step 4: Set Up Kubernetes (Master & Worker Nodes)**
### ** Install Kubernetes on Both Servers**
Run on both **Master & Worker Nodes**:
```bash
sudo apt update -y
sudo apt install -y curl apt-transport-https
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubeadm kubelet kubectl
sudo systemctl enable kubelet && sudo systemctl start kubelet
```

### **2 Initialize Kubernetes on Master**
```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```
Copy the **join command** and run it on the Worker Node:
```bash
kubeadm join <Server4_Master_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

### **3 Verify Cluster**
```bash
kubectl get nodes
```

---

## ** Step 5: Configure CI/CD Pipeline in Jenkins**
### **Jenkinsfile**
```groovy
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "jagadesh999/simple-webapp:latest"
    }
    stages {
        stage('Build') {
            steps { sh 'mvn clean package' }
        }
        stage('SonarQube Analysis') {
            steps { sh 'mvn sonar:sonar -Dsonar.host.url=http://<Server3_IP>:9000' }
        }
        stage('Push to Nexus') {
            steps { sh 'mvn deploy -DaltDeploymentRepository=nexus::default::http://<Server2_IP>:8081/repository/maven-releases/' }
        }
        stage('Build & Push Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
                sh 'docker push $DOCKER_IMAGE'
            }
        }
        stage('Deploy to Kubernetes') {
            steps { sh 'kubectl apply -f k8s-deployment.yaml' }
        }
    }
}
```

---

## ** Step 6: Kubernetes Deployment**
### **`k8s-deployment.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: simple-webapp-service
spec:
  selector:
    app: simple-webapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

 **Final Deployment URL:**
```
http://<LoadBalancer_IP>
```
 **Web App Message:**
> *"Keep your face always toward the sunshine—and shadows will fall behind you."*

