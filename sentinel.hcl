module "tfplan-functions" {
  source = "./common-functions/tfplan-functions/tfplan-functions.sentinel"
}



policy "validate-ingress-sg-rule-cidr-blocks" {
    enforcement_level = "hard-mandatory"
}

policy "restrict-iam-policy-statement2" {
    enforcement_level = "hard-mandatory"
}


