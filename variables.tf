variable "sso_base_url" {
  description = "URL the IDP will send SAML auth requests. Ex. vpn.fortigate.com:4443"
  type        = string
}

variable "entity_id" {
  description = "Override the SP entity ID"
  type        = string
  default     = null
}

variable "digest_method" {
  description = "Digest Method Algorithm."
  type        = string
  default     = "sha1"
}

variable "idp_cert" {
  description = "IDP certificate as base64."
  type        = string
}

variable "vdom" {
  description = "Name of VDOM to create SAML user on."
  type        = string
  default     = null
}

variable "idp_info" {
  description = "IDP information."
  type = object({
    idp_entity_id          = string
    idp_single_logout_url  = string
    idp_single_sign_on_url = string
  })
}

variable "username_assertion" {
  description = "Attribute in assertion to map to username."
  type        = string
  default     = "username"
}

variable "group_assertion" {
  description = "Attribute in assertion to map to groups."
  type        = string
  default     = "groups"
}

variable "custom_name" {
  description = "Custom object name."
  type        = string
  default     = null
}