package terraform.cis

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "aws_subnet"
  rc.change.after.map_public_ip_on_launch == true

  name := subnet_name(rc.change.after.tags)

  # Allow only the NAT helper subnet to be public
  name != "public-nat-subnet"

  msg := sprintf("CIS: Deny public subnet. aws_subnet %q sets map_public_ip_on_launch=true (only public-nat-subnet is allowed).", [rc.name])
}

subnet_name(tags) = name {
  name := tags.Name
} else = "unknown" {
  true
}
