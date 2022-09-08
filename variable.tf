variable "public_cidr" {
  type=list(any)
  default =["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
}
variable "private_cidr" {
type=list(any)
  default =["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
}
variable "data_cidr" {
  type=list(any)
  default =["10.2.6.0/24", "10.2.7.0/24", "10.2.8.0/24"]
}