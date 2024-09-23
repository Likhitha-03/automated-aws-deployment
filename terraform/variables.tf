variable "ami" {
  description = "The AMI to use for the EC2 instance"
  type        = string
  default     = "ami-0ebfd941bbafe70c6"  
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}
