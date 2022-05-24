# vpc id 
output "tdcs_vpc_id" {
    value = aws_vpc.tdcs_vpc.id
    description = "value of vpc id"
}

#unique private backend subnet list 
output "tdcs_unique_backend_subnet_ids" {
    value = aws_subnet.tdcs_private_unique_backend_subnet.*.id
}

#duplicate backend subnet list
output "tdcs_dup_back_subnet_ids" {
    value = aws_subnet.tdcs_private_dup_backend_subnet.*.id
}

# private backend subnet list
output "tdcs_private_backend_subnet_ids" {
    value = aws_subnet.tdcs_private_backend_subnet.*.id
}


# private backend subnet list
output "tdcs_public_front_subnet_ids" {
    value = aws_subnet.tdcs_public_front_subnet.*.id
}

# nat gateway info 
output "tdcs_natgateway_public" {
    value = aws_nat_gateway.tdcs_nat_public.*.id
}

