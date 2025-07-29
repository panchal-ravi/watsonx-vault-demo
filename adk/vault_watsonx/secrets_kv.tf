

# this is pre-existing kv path

# Admin-level secrets (only admins can access)
resource "vault_kv_secret_v2" "admin_secret" {
  namespace = var.namespace != null ? var.namespace : null
  mount     = "kv"  # Use existing KV mount
  name      = "watsonxdemo/admin/database"
  
  data_json = jsonencode({
    username = "admin_user"
    password = "super_secret_admin_password"
    host     = "admin-db.internal.com"
    port     = "5432"
    database = "admin_db"
  })
}

resource "vault_kv_secret_v2" "admin_api_keys" {
  namespace = var.namespace != null ? var.namespace : null
  mount     = "kv"  # Use existing KV mount
  name      = "watsonxdemo/admin/api-keys"
  
  data_json = jsonencode({
    production_api_key = "prod-api-key-12345-super-secret"
    staging_api_key    = "stage-api-key-67890"
    azure_subscription_key = "azure-key-abcdef"
  })
}

# User-level secrets (both admins and users can access)
resource "vault_kv_secret_v2" "user_secret" {
  namespace = var.namespace != null ? var.namespace : null
  mount     = "kv"  # Use existing KV mount
  name      = "watsonxdemo/shared/application"
  
  data_json = jsonencode({
    app_name = "WatsonX Demo Application"
    version  = "1.0.0"
    config = {
      debug_mode = "false"
      log_level  = "info"
    }
  })
}

resource "vault_kv_secret_v2" "common_config" {
  namespace = var.namespace != null ? var.namespace : null
  mount     = "kv"  # Use existing KV mount
  name      = "watsonxdemo/shared/config"
  
  data_json = jsonencode({
    environment     = "demo"
    region         = "us-east-1"
    support_email  = "support@watsonxdemo.com"
    public_endpoints = {
      api_url = "https://api.watsonxdemo.com"
      web_url = "https://watsonxdemo.com"
    }
  })
}

# Test secret that should fail for users (admin path)
resource "vault_kv_secret_v2" "restricted_secret" {
  namespace = var.namespace != null ? var.namespace : null
  mount     = "kv"  # Use existing KV mount
  name      = "watsonxdemo/admin/vault-root-token"
  
  data_json = jsonencode({
    root_token = "hvs.SUPER_SECRET_ROOT_TOKEN_FOR_VAULT"
    warning    = "This should only be accessible by admins!"
  })
}