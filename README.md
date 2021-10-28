<!-- BEGIN_TF_DOCS -->
# terraform-fortios-samlsp

Requires forked version of fortios provider to support certificate management

Will create a SAML service provider. Default assertion attributes from IDP are username and groups.

Groups will be needed to created and this SAML user added to the group as required.

## Usage:

### Example of 'terraform-fortios-samlsp' module.

```hcl
terraform {
  backend "local" {}

  required_providers {
    fortios = {
       source  = "poroping/fortios"
       version = ">= 2.3.0"
    }
  }
}

provider "fortios" {
  vdom     = "root"
  insecure = "true"
}

locals {
  aadcert = <<EOF
-----BEGIN CERTIFICATE-----
MIIC2jCCAkMCAg38MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwG
A1UECBMFVG9reW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNERE
MRgwFgYDVQQLEw9XZWJDZXJ0IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdl
YiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9ydEBmcmFuazRkZC5jb20wHhcNMTIw
ODIyMDUyNzQxWhcNMTcwODIxMDUyNzQxWjBKMQswCQYDVQQGEwJKUDEOMAwGA1UE
CAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhhbXBs
ZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0z9FeMynsC8+u
dvX+LciZxnh5uRj4C9S6tNeeAlIGCfQYk0zUcNFCoCkTknNQd/YEiawDLNbxBqut
bMDZ1aarys1a0lYmUeVLCIqvzBkPJTSQsCopQQ9V8WuT252zzNzs68dVGNdCJd5J
NRQykpwexmnjPPv0mvj7i8XgG379TyW6P+WWV5okeUkXJ9eJS2ouDYdR2SM9BoVW
+FgxDu6BmXhozW5EfsnajFp7HL8kQClI0QOc79yuKl3492rH6bzFsFn2lfwWy9ic
7cP8EpCTeFp1tFaD+vxBhPZkeTQ1HKx6hQ5zeHIB5ySJJZ7af2W8r4eTGYzbdRW2
4DDHCPhZAgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAQMv+BFvGdMVzkQaQ3/+2noVz
/uAKbzpEL8xTcxYyP3lkOeh4FoxiSWqy5pGFALdPONoDuYFpLhjJSZaEwuvjI/Tr
rGhLV1pRG9frwDFshqD2Vaj4ENBCBh6UpeBop5+285zQ4SI7q4U9oSebUDJiuOx6
+tZ9KynmrbJpTSi0+BM=
-----END CERTIFICATE-----

EOF
}

module "name" {
  source = "/home/justinr/tf-modules/terraform-fortios-samlsp"

  vdom = "root"
  idp_cert = local.aadcert
  sso_base_url = "vpn.example.com:9443"
  idp_info = {
    idp_entity_id = "https://sts.windows.net/xxxyyyzzz/"
    idp_single_logout_url = "https://login.microsoftonline.com/xxxyyyzzz/saml2"
    idp_single_sign_on_url = "https://login.microsoftonline.com/xxxyyyzzz/saml2"
  }
}

resource "fortios_user_group" "saml_group" {
  name = "SAML"
  member {
    name = module.name.saml_sp_name
  }
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_fortios"></a> [fortios](#provider\_fortios) | >= 2.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_idp_cert"></a> [idp\_cert](#input\_idp\_cert) | IDP certificate as base64. | `string` | n/a | yes |
| <a name="input_idp_info"></a> [idp\_info](#input\_idp\_info) | IDP information. | <pre>object({<br>    idp_entity_id          = string<br>    idp_single_logout_url  = string<br>    idp_single_sign_on_url = string<br>  })</pre> | n/a | yes |
| <a name="input_sso_base_url"></a> [sso\_base\_url](#input\_sso\_base\_url) | URL the IDP will send SAML auth requests. Ex. vpn.fortigate.com:4443 | `string` | n/a | yes |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Custom object name. | `string` | `null` | no |
| <a name="input_digest_method"></a> [digest\_method](#input\_digest\_method) | Digest Method Algorithm. | `string` | `"sha1"` | no |
| <a name="input_group_assertion"></a> [group\_assertion](#input\_group\_assertion) | Attribute in assertion to map to groups. | `string` | `"groups"` | no |
| <a name="input_username_assertion"></a> [username\_assertion](#input\_username\_assertion) | Attribute in assertion to map to username. | `string` | `"username"` | no |
| <a name="input_vdom"></a> [vdom](#input\_vdom) | Name of VDOM to create SAML user on. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_saml_sp_name"></a> [saml\_sp\_name](#output\_saml\_sp\_name) | Name of created SAML SP. |
<!-- END_TF_DOCS -->