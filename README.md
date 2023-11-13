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
For this deployment, we create Docker images for both the frontend and backend layers. This approach will create a microservices architecture, essentailly linking the backend layer to the frontend later. Those images will alter be deployed on Amazon ECS.
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
Similarly, the backend Dockerfile will set up the backend environment, pulling from our repository within the backend folder. It would also install its Python requirement and set up the server to be ready on port 8000.
<br>
<br>
Please note that both Docker images were built and tested to ensure they were functioning properly before deploying to Amazon ECS. 

#### Creating Jenkinsfile
We utilize two different Jenkinsfile and 









Next, we created an ecs and vpc Terraform [file](https://github.com/DarrielleEvans/deployment8/blob/main/terraform/main.tf) to create the following resources in our infrastructure:
 - 2 Availability Zones
 - 2 Public Subnets
 - 2 Containers for the front end
 - 1 Container for the backend
 - 1 Route Table
 - Security Group Ports: 8000, 3000, 80
 - 1 Application Load Balancer

In our fourth step, we created a [Jenkins file](https://github.com/DarrielleEvans/deployment8/blob/main/Jenkinsfile_BE) to deploy the ECS Terraform files for the backend. After the initial deployment, we made sure to copy the private ip address and place it in the package.json file so that the front end can connect with the backend.
We also created a [Jenkins file](https://github.com/DarrielleEvans/deployment8/blob/main/Jenkinsfile_BE) to deploy the ECS Terraform files for the front end.







## System Design Diagram
![d8 drawio](https://github.com/DarrielleEvans/deployment8/assets/89504317/8b964f44-6ce7-4a43-aa2f-b43299f11ead)


## Issues and Troubleshooting


## Optimization

## Notes
The ecommerce application's stack uses the following:
  - Front end: React
  - Back end: Python using Django Framework
  - Database: SQlite3
  - CI/CD: Jenkins
  - AWS Cloud technologies
  - AWS Elastic Container Services


