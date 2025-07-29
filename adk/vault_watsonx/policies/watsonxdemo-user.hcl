# Policy for watsonxdemo Regular Users (via Azure AD Vault-Users group)
# Provides read-only access to watsonxdemo secrets with limited system access

# Allow reading own token information
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow renewing own token
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow checking capabilities
path "sys/capabilities-self" {
    capabilities = ["update"]
}

# Allow listing metadata at root level (for navigation)
path "kv/metadata" {
    capabilities = ["list"]
}

# Read-only access to watsonxdemo secrets
path "kv/metadata/watsonxdemo" {
    capabilities = ["read", "list"]
}

path "kv/metadata/watsonxdemo/*" {
    capabilities = ["read", "list"]
}

path "kv/data/watsonxdemo" {
    capabilities = ["read"]
}

path "kv/data/watsonxdemo/*" {
    capabilities = ["read"]
}

# Limited access using entity templating (users can manage their own user-specific secrets)
path "kv/data/users/{{identity.entity.name}}" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/data/users/{{identity.entity.name}}/*" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/metadata/users/{{identity.entity.name}}" {
    capabilities = ["read", "list", "delete"]
}

path "kv/metadata/users/{{identity.entity.name}}/*" {
    capabilities = ["read", "list", "delete"]
}

# KV-v1 fallback paths - read-only for watsonxdemo
path "kv/watsonxdemo" {
    capabilities = ["read"]
}

path "kv/watsonxdemo/*" {
    capabilities = ["read"]
}

# KV-v1 fallback paths - full access to user's own space
path "kv/users/{{identity.entity.name}}" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/users/{{identity.entity.name}}/*" {
    capabilities = ["create", "read", "update", "delete"]
}
