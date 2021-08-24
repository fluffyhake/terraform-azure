variable "username" {
#    default = "*"
}

variable "password" {
#    default = "*"
}


module "myawesomewindowsvm" {
    source = "../../modules/my_virtual_machine"
    name = "hrawsmapp"
    vm_size = "Standard_A2_V2"
    username = "${var.username}"
    password = "${var.password}"
}

module "differentwindowsvm" {
  domainname = "hrimdifferent"
  source = "../../modules/my_virtual_machine"
  name   = "hrimDiff"
  vm_size  = "Standard_A2_v2"
  username = "${var.username}"
  password = "${var.password}" }
