output "saml_sp_name" {
  description = "Name of created SAML SP."
  value       = fortios_user_saml.saml_auth.name
}