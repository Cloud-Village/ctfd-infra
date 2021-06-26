variable "packer_image_id" {
  type        = string
  description = "ami build by packer"
}

variable "template_az" {
  type        = string
  description = "availability zone used by the launch template"
}

variable "key_name" {
  type        = string
  description = "ec2 keypair"
}

variable "vpc_id" {
  type        = string
  description = "vpc_id that all the things will live in"
}


variable "availability_zones" {
  type        = list(string)
  description = "availability zones where things will live"
}

variable "max_size" {
  type        = number
  description = "what is the maximum size of the autoscaling group?"
}

variable "desired_capacity" {
  type        = number
  description = "how many nodes should there be to start? at least the same number of availability zones"
  default     = 2
}

variable "alb_subnets" {
  type        = list(string)
  description = "subnet ids the ALB should live in"
}

variable "certificate_arn" {
  type        = string
  description = "ARN for the SSL certificate used by the ALB"
}

variable "uploads_bucket_name" {
  description = "name of the bucket for uploads"
  type        = string
}

variable "route53_zone_id" {
  type        = string
  description = "hosted zone id"
}

variable "redis_node_type" {
  type        = string
  description = "type of nodes to use for redis"
}

variable "region" {
  type        = string
  description = "aws region the resources will be created in"
}

variable "create_aws_dns" {
  type        = bool
  description = "do you want to create DNS entries in route53?"
  default     = false
}

variable "inbound_ips" {
  description = "list of allowed inbound IP addresses"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ctfd_version" {
  type        = string
  description = "docker tag for CTFd version"
  default     = "mark-3.3.0"
}

variable "workers" {
  type        = string
  description = "number of gunicorn workers"

}

variable "mailfrom_addr" {
  type        = string
  description = "The email address that emails are sent from if not overridden in the configuration panel."
}


variable "mail_server" {
  type        = string
  description = "The mail server that emails are sent from if not overriden in the configuration panel."
}

variable "mail_port" {
  type        = string
  description = "The mail port that emails are sent from if not overriden in the configuration panel."
}

variable "ecs_subnets" {
  type        = list(string)
  description = "subnets used by the ECS service"
}

variable "logs_region" {
  type        = string
  description = "region to store logs"
}


