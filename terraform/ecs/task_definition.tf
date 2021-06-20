locals {
  task_family_name = var.name
}

resource "aws_ecs_task_definition" "task" {
  family       = local.task_family_name
  network_mode = "awsvpc"
  cpu          = "256"
  memory       = "512"


  container_definitions = jsonencode([
    {
      name      = "ctfd"
      image     = "ctfd/ctfd:${var.ctfd_tag}"
      essential = true

      "secrets" : [
        { "name" : "AWS_ACCESS_KEY_ID", "value" : "${var.aws_access_key}" },
        { "name" : "AWS_SECRET_ACCESS_KEY", "value" : "${var.aws_secret_access_key}" },
        { "name" : "MAIL_USERNAME", "value" : "${var.mail_username}" },
        { "name" : "MAIL_PASSWORD", "value" : "${var.mail_password}" },
        { "name" : "DATABASE_URL", "value" : "{var.database_url}" },

      ],

      "environment" : [
        { "name" : "WORKERS", "value" : "${var.workers}" },
        { "name" : "SECRET_KEY", "value" : "${var.secret_key}" },
        { "name" : "AWS_S3_BUCKET", "value" : "${var.s3_bucekt}" },
        { "name" : "MAILFROM_ADDR", "value" : "${var.mailfrom_addr}" },
        { "name" : "MAIL_SERVER", "value" : "${var.mail_server}" },
        { "name" : "MAIL_PORT", "value" : "${var.mail_port}" },
        { "name" : "REDIS_URL", "value" : "${var.redis_url}" },
        { "name" : "UPLOAD_PROVIDER", "value" : "s3" },
        { "name" : "MAIL_USEAUTH", "value" : "true" },
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.task_family_name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 8000
        }
      ]
    },
  ])

  requires_compatibilities = ["FARGATE"]

  tags {
    name         = local.task_family_name
    ctfd_version = var.ctfd_version
  }

}


