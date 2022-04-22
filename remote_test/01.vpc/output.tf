# vpc id 
output "smp_vpc_id" {
    value = aws_vpc.api_vpc.id
    description = "value of vpc id"
}

#unique private backend subnet list 
output "smp_unique_backend_subnet_ids" {
    value = aws_subnet.api_private_unique_backend_subnet.*.id
}

#duplicate backend subnet list
output "smp_dup_back_subnet_ids" {
    value = aws_subnet.api_private_dup_backend_subnet.*.id
}

# private backend subnet list
output "smp_private_backend_subnet_ids" {
    value = aws_subnet.api_private_backend_subnet.*.id
}


# private backend subnet list
output "smp_public_dup_front_subnet_ids" {
    value = aws_subnet.api_public_dup_front_subnet.*.id
}

# nat gateway info 
output "smp_nat_gate_ways" {
    value = aws_nat_gateway.api_nat_front.*.id
}

