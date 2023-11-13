# Deployment 8 Documentation 
## Meet the Team:
Darrielle - Project Manager <br>
Nehemish - System Administrator <br>
Aubrey - Chief Architect <br>

## Purpose:
The primary goal of Deployment 8 is to familiarize ourselves with containerizing our e-commerce application using Amazon Elastic Container Services (ECS). We also use Docker as well as Terraform. This e-commerce application integrates microservices for the front end as well as the back end. In addition, we also implemented an application load balancer to balance traffic to the frontend containers. This deployment enhances our technical skills in cloud-based environments and strengthens our teamwork skills. Throughout the project, we collectively worked as a team to navigate those complex deployment problems.


## Steps:
We began this deployment by creating a branch for each of our roles in Git.

#### Create the First AWS Infrastructure with Terraform 
We creating a new AWS infrastructure using this [Terrafrom](https://github.com/DarrielleEvans/deployment8/blob/main/first-infrastucture/main.tf). This tf file is designed to create three different instances for three different purposes. Each instance has a different configuration using different user data. Here is a detailed explanation:
 - Jenkins Instance: click [here](https://github.com/DarrielleEvans/deployment8/blob/main/first-infrastucture/deployjenkins.sh) to checkout the user data script.
 - Terraform Instance: click [here](https://github.com/DarrielleEvans/deployment8/blob/main/first-infrastucture/deployterraform.sh) to checkout the user data script.
 - Docker Instance: click [here](https://github.com/DarrielleEvans/deployment8/blob/main/first-infrastucture/deploydocker.sh) to checkout the user data script.


#### Building Docker Images for Frontend and Backend Layers
For this deployment, we create Docker images for both the frontend and backend layers. This approach will create a microservices architecture, essentially linking the backend layer to the frontend later. Those images will alter be deployed on Amazon ECS.
- Frontend Dockerfile:
```
FROM node:10
RUN git clone https://github.com/DarrielleEvans/deployment8.git
WORKDIR /deployment8/frontend
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
```
This Dockerfile will set up the frontend environment, grabbing the latest code from our repository within the frontend folder. It would then install its dependencies and prepare the service to be run on port 3000.

- Backend Dockerfile:
```
FROM python:3.7
RUN git clone https://github.com/DarrielleEvans/deployment8.git
WORKDIR /deployment8/backend/
RUN pip install -r requirements.txt
RUN python manage.py migrate
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```
Similarly, the backend Dockerfile will set up the backend environment, pulling from our repository within the backend folder. It would also install its Python requirements and set up the server to be ready on port 8000.
<br>
<br>
Please note that both Docker images were built and tested to ensure they were functioning properly before deploying to Amazon ECS. 

#### Creating Jenkinsfile
We utilize two distinct Jenkins files in this deployment: one for the backend and another for the frontend. We would begin by running the backend Jenkinsfile, and once that was successful, we would retrieve the private IP of the backend service. This IP would then be inserted into `proxy` in the frontend's `package.json`, allowing the front end to connect to the backend. Before we ran the Jenkinsfile, we had to make sure we had our necessary credentials in Jenkins credentials

[Backend Jenkinsfile Pipeline](https://github.com/DarrielleEvans/deployment8/blob/main/Jenkinsfile_BE)
1) Docker Build and Push Backend image
2) [Backend Terraform file](https://github.com/DarrielleEvans/deployment8/blob/main/terraform/main.tf): After the Docker image is successfully pushed, the pipeline will move to the Terraform agent. Here is what Terraform for the backend is creating:
   - 1 VPC
   - 2 Available zones
   - 2 Public Subnet
   - 1 Route Table
   - 1 Internet Gateway
   - 1 Security Group: allowing traffic on ports 80, 3000, 8000
   - ECS Cluster: for this application
   - Backend log with Cloudwatch
   - ECS Task Definition for Backend
   - ECS Service for Backend
   - ALB Target Group for Backend
   - Application Load Balancer for the E-commerce application
   - Backend Listener.
After the completion of the backend pipeline, we would check the infrastructure to ensure all components are functioning.

[Frontend Jenkinsfile Pipeline](https://github.com/DarrielleEvans/deployment8/blob/main/Jenkinsfile_FE)
1) Docker Build and Push Frontend Image
2) [Frontend Terraform file](https://github.com/DarrielleEvans/deployment8/blob/main/terraform/frontend/main.tf): after the frontend Docker image is successfully pushed, the pipeline will move to the Terraform agent to create the frontend infrastructure. Here is what it's creating:
   - Grab information from the existing infrastructure, like subnets, VPCs, clusters, and ALB.
   - Frontend log with Cloudwatch
   - ECS Task for Frontend
   - ECS Service for Frontend within the Cluster
   - ALB Target Group for Frontend within the VPC
   - Frontend Listenser within the ALB.

After running and completing this frontend pipeline, we can check the infrastructure as well as the application using the ALB DNS. 
![image_720](https://github.com/DarrielleEvans/deployment8/assets/138344000/ed44cc1c-83f7-43c7-b113-c0d463105eec)

## System Design Diagram
![image](https://github.com/DarrielleEvans/deployment8/assets/138344000/cd39ab6f-7d20-4b9e-9ca1-1e57d73ce3c5)
To view the full system design diagram, click [here](https://github.com/DarrielleEvans/deployment8/blob/main/d8.drawio.png).

## Issues and Troubleshooting
- Invalid Host Error: We encountered an invalid host error, which we fixed by modifying the `package.json` file within the frontend folder. We added a configuration that would disable the host check
![image](https://github.com/DarrielleEvans/deployment8/assets/138344000/326cec76-0aab-4a56-8df3-44e7c6fa0e83)
- Docker Hub Image Conflict: Another issue we faced involved ECS pulling the wrong image from Dockerhub. To fix this, we deleted the repository in Docker Hub and rerun Jenkins to repush the image.

## Optimization
- Enhanced Security: Currently, we place all containers in a public subnet, posing a security risk. To fix this, we plan to move that container into a private subnet.
- Backend Container: For this deployment, we have only one backend container. To optimize, we would like to add a backend container.
- Application Scaling: We would also like to implement a way to scale the application by adding Auto Scaling Group, etc. 


## Commonly Asked Question
What is the application stack of this application?
- Frontend: React/ Nodejs
- Backend: SQLite, Python, Django 

Is the backend an API server?
- Currently, the backend wold act as a API server.

