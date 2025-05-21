# Terraform Registry Supply Chain Attack

How Terraform loads modules from the Terraform Registry:
https://github.com/hashicorp/terraform/blob/572d12bfd39af7f50dacaad16a671099716b9963/internal/registry/client.go#L212-L228

How OpenTofu loads modules:
https://github.com/opentofu/registry/blob/a6e20a05df5eb7ff3ee1b7a47fe652e61cc0412d/src/internal/module/module.go#L50-L52

Vulnerability report from 2018:
https://github.com/hashicorp/terraform/issues/17110


Azure login:
```
az account clear
az config set core.enable_broker_on_windows=false
az login --allow-no-subscription
```
