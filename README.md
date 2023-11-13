# Deployment 8 Documentation 

## Purpose:
The primary goal of Deployment 7 is to familiarize ourselves with containerizing our ecom application on ECS. We also gained hands-on experience working with Docker as well as Terraform. This ecom application integrates microservices for the front end as well as the back end. In addition, we also implemented an application load balancer to balance traffic to the frontend containers. This deployment allows us to learn how to work as a team as well as look for ways to mitigate configuration and create microservices.


## Steps:
First, we used Terraform to create a Jenkins manager/agent architecture using 3 instances. Each instance has a specific configuration using different user data.
 - Jenkins Instance: click [here](https://github.com/DarrielleEvans/deployment8/blob/main/first-infrastucture/deployjenkins.sh) to checkout the user data script.
 - Terraform Instance: click [here](https://github.com/DarrielleEvans/deployment8/blob/main/first-infrastucture/deployterraform.sh) to checkout the user data script.
 - Docker Instance: click [here](https://github.com/DarrielleEvans/deployment8/blob/main/first-infrastucture/deploydocker.sh) to checkout the user data script.
In previous exercises, we deployed the application in a single container. In this deployment, we separated our front end and back end in separate containers. In step 2, we created docker images by specifying the instructions needed to build the Docker image.






## System Design Diagram


## Issues and Troubleshooting


## Optimization

