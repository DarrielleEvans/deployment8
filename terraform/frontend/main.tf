provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"
}

###################### Creating a log group ##################################
resource "aws_cloudwatch_log_group" "frontend-logs" {
  name = "/ecs/frontend-logs"
  tags = {
    Application = "d8-app"
  }
}



################### Create a Task ##########################################
resource "aws_ecs_task_definition" "frontend" {
  family = "d8-frontend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::393598274403:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::393598274403:role/ecsTaskExecutionRole"

  container_definitions = <<EOF
  [
    {
    "name": "frontend-container",
    "image": "aubreyz/frontend2:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/frontend-logs",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": 3000
      }
    ]
  }
  ]
  EOF

}

data "aws_subnet" "public1"{
    cidr_block = "172.55.64.0/18"
}

data "aws_subnet" "public2"{
    cidr_block = "172.55.128.0/18"
}

data "aws_vpc" "main"{
    cidr_block = "172.55.0.0/16"
}
data "aws_alb" "d8-alb"{
    name = "d8-alb"
}
data "aws_ecs_cluster" "ecs_cluster"{
    cluster_name = "deployment8-cluster"
}
data "aws_security_group" "sg" {
    name = "d8_sg"
}
##################### creatine ecs service ########################################
resource "aws_ecs_service" "frontend_service" {
  name = "frontend_service"
  cluster = data.aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count = 2
  force_new_deployment = true
  
  network_configuration {
    subnets = [
      data.aws_subnet.public1.id,
      data.aws_subnet.public2.id,
    ]
    assign_public_ip = true
    security_groups = [data.aws_security_group.sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_target.arn
    container_name   = "frontend-container"
    container_port   = 3000
  }
  depends_on = [ aws_alb_listener.frontend_listener ]
}

#################### Target groups #########################
resource "aws_lb_target_group" "frontend_target" {
  name = "frontend-target"
  port = 3000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = data.aws_vpc.main.id

  health_check {
    enabled = true
    path = "/health"
  }
 ## depends_on = [ aws_alb.d8-alb ]
}

resource "aws_alb_listener" "frontend_listener" {
  load_balancer_arn = data.aws_alb.d8-alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend_target.arn
  }
}
