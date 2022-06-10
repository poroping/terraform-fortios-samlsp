/**
 * # terraform-fortios-samlsp
 * 
 * Requires forked version of fortios provider to support certificate management
 * 
 * Will create a SAML service provider. Default assertion attributes from IDP are username and groups.
 * 
 * Groups will be needed to created and this SAML user added to the group as required.
 * 
 * ## Usage:
 *
 * ### Example of 'terraform-fortios-samlsp' module.
 *
 *
 * ```hcl
 * terraform {
 *   backend "local" {}
 * 
 *   required_providers {
 *     fortios = {
 *        source  = "poroping/fortios"
 *        version = ">= 2.3.0"
 *     }
 *   }
 * }
 * 
 * provider "fortios" {
 *   vdom     = "root"
 *   insecure = "true"
 * }
 * 
 * locals {
 *   aadcert = <<EOF
 * -----BEGIN CERTIFICATE-----
 * MIIC2jCCAkMCAg38MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwG
 * A1UECBMFVG9reW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNERE
 * MRgwFgYDVQQLEw9XZWJDZXJ0IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdl
 * YiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9ydEBmcmFuazRkZC5jb20wHhcNMTIw
 * ODIyMDUyNzQxWhcNMTcwODIxMDUyNzQxWjBKMQswCQYDVQQGEwJKUDEOMAwGA1UE
 * CAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhhbXBs
 * ZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0z9FeMynsC8+u
 * dvX+LciZxnh5uRj4C9S6tNeeAlIGCfQYk0zUcNFCoCkTknNQd/YEiawDLNbxBqut
 * bMDZ1aarys1a0lYmUeVLCIqvzBkPJTSQsCopQQ9V8WuT252zzNzs68dVGNdCJd5J
 * NRQykpwexmnjPPv0mvj7i8XgG379TyW6P+WWV5okeUkXJ9eJS2ouDYdR2SM9BoVW
 * +FgxDu6BmXhozW5EfsnajFp7HL8kQClI0QOc79yuKl3492rH6bzFsFn2lfwWy9ic
 * 7cP8EpCTeFp1tFaD+vxBhPZkeTQ1HKx6hQ5zeHIB5ySJJZ7af2W8r4eTGYzbdRW2
 * 4DDHCPhZAgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAQMv+BFvGdMVzkQaQ3/+2noVz
 * /uAKbzpEL8xTcxYyP3lkOeh4FoxiSWqy5pGFALdPONoDuYFpLhjJSZaEwuvjI/Tr
 * rGhLV1pRG9frwDFshqD2Vaj4ENBCBh6UpeBop5+285zQ4SI7q4U9oSebUDJiuOx6
 * +tZ9KynmrbJpTSi0+BM=
 * -----END CERTIFICATE-----
 *
 * EOF
 * }
 * 
 * module "name" {
 *     source  = "poroping/samlsp/fortios"
 *     version = ">= 0.0.1"
 *   
 *   vdom = "root"
 *   idp_cert = local.aadcert
 *   sso_base_url = "vpn.example.com:9443"
 *   idp_info = {
 *     idp_entity_id = "https://sts.windows.net/xxxyyyzzz/"
 *     idp_single_logout_url = "https://login.microsoftonline.com/xxxyyyzzz/saml2"
 *     idp_single_sign_on_url = "https://login.microsoftonline.com/xxxyyyzzz/saml2"
 *   }
 * }
 * 
 * resource "fortios_user_group" "saml_group" {
 *   name = "SAML"
 *   member {
 *     name = module.name.saml_sp_name
 *   }
 * }
 * ```
 *
 * 
 */

terraform {
  required_providers {
    fortios = {
      source  = "poroping/fortios"
      version = ">= 2.3.0"
    }
    random = {}
  }
}

resource "random_id" "cert" {
  byte_length = 4

  keepers = {
    cert = var.idp_cert
  }
}

resource "fortios_certificate_management_remote" "samlcert" {
  vdomparam = var.vdom

  name        = var.custom_name == null ? "SAML-Remote-${random_id.cert.hex}" : var.custom_name
  certificate = random_id.cert.keepers.cert
  scope       = "vdom"
}

resource "fortios_user_saml" "saml_auth" {
  vdomparam = var.vdom

  entity_id              = var.entity_id == null ? "https://${var.sso_base_url}/remote/saml/metadata/" : var.entity_id
  idp_cert               = fortios_certificate_management_remote.samlcert.name
  idp_entity_id          = var.idp_info.idp_entity_id
  idp_single_logout_url  = var.idp_info.idp_single_logout_url
  idp_single_sign_on_url = var.idp_info.idp_single_sign_on_url
  name                   = var.custom_name == null ? "SAML-${random_id.cert.hex}" : var.custom_name
  single_logout_url      = "https://${var.sso_base_url}/remote/saml/logout/"
  single_sign_on_url     = "https://${var.sso_base_url}/remote/saml/login/"
  user_name              = var.username_assertion
  group_name             = var.group_assertion == null ? null : var.group_assertion
}
