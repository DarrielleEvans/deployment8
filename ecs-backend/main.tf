provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = "us-east-1"
}

####################################VPC ########################
resource "aws_vpc" "main" {
  cidr_block = "172.55.0.0/16"
  tags = {
    Name = "d8_vpc"
  }
}

#################### 2 Subnets ##########################
resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.55.64.0/18"
  availability_zone = "us-east-1a"

  tags = {
    Name = "d8_publicsubnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.55.128.0/18"
  availability_zone = "us-east-1b"

  tags = {
    Name = "d8_publicsubnet2"
  }
}

#################### Route Table #######################
resource "aws_route_table" "public" {
 vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "publicsubnet1" {
  subnet_id      = aws_subnet.public1.id 
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "publicsubnet2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

################# Creating interent gateway ##########################
resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.main.id
}

################ Creating Security group ##########################
resource "aws_security_group" "sg" {
  name = "d8_sg"
  description = "traffic for d8"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8000
    to_port = 8000 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


############################# Route to Internet gateway ######################
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet.id
}

##########################Creating Cluster#####################################
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "deployment8-cluster"
  tags = {
    Name = "deployment -8-ecs"
  }
}

resource "aws_cloudwatch_log_group" "backend-logs" {
  name = "/ecs/backend-logs"
  tags = {
    Application = "d8-app"
  }
}



resource "aws_ecs_task_definition" "backend" {
  family = "d8-backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::393598274403:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::393598274403:role/ecsTaskExecutionRole"

  container_definitions = <<EOF
  [
  {
      "name": "backend-container",
      "image": "aubreyz/backend:latest",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/backend-logs",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 8000
        }
      ]
    }
  ]
  EOF

}

resource "aws_ecs_service" "backend_service" {
  name = "backend_service"
  cluster = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count = 1
  force_new_deployment = true
  
  network_configuration {
    subnets = [
      aws_subnet.public1.id,
    ]
    assign_public_ip = true
    security_groups = [aws_security_group.sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_target.arn
    container_name   = "backend-container"
    container_port   = 8000
  }
  depends_on = [ aws_alb_listener.backend_listener ]
}


resource "aws_lb_target_group" "backend_target" {
  name = "backend-target"
  port = 8000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.main.id

  health_check {
    enabled = true
    path = "/health"
  }
  depends_on = [ aws_alb.d8-alb ]
}

#################### Application load balancer ########################
resource "aws_alb" "d8-alb" {
  name = "d8-alb"
  internal = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
  ]
  security_groups = [aws_security_group.sg.id]

  depends_on = [ aws_internet_gateway.internet ]
}

################ Listener ######################################


resource "aws_alb_listener" "backend_listener" {
  load_balancer_arn = aws_alb.d8-alb.arn
  port = "8000"
  protocol = "HTTP"
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_target.arn
  }
}
