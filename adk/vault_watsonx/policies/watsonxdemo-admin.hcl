# Policy for watsonxdemo Admin Users (via Azure AD Vault-Admins group)
# Provides administrative access to watsonxdemo secrets and system information

# Allow reading own token information
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow renewing own token
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow listing mounted secret engines
path "sys/mounts" {
    capabilities = ["read"]
}

# Allow checking capabilities
path "sys/capabilities-self" {
    capabilities = ["update"]
}

# Allow reading system health and seal status (admin privileges)
path "sys/health" {
    capabilities = ["read"]
}

path "sys/seal-status" {
    capabilities = ["read"]
}

# Allow listing auth methods (admin insight)
path "sys/auth" {
    capabilities = ["read"]
}

# Allow listing policies (admin insight)
path "sys/policies/acl" {
    capabilities = ["list"]
}

# Admin access to all watsonxdemo secrets (full CRUD)
path "kv/metadata" {
    capabilities = ["list"]
}

path "kv/metadata/watsonxdemo" {
    capabilities = ["read", "list", "delete"]
}

path "kv/metadata/watsonxdemo/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/watsonxdemo" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/watsonxdemo/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow admin to access any tenant's secrets (super admin)
path "kv/data/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/metadata/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# KV-v1 fallback paths with full access
path "kv/watsonxdemo" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/watsonxdemo/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow admin to manage any tenant paths
path "kv/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
