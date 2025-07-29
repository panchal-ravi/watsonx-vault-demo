# Policy for watsonxdemo Admin Users (via Azure AD Vault-Admins group)
# Application-focused policy using group templating

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

# Full access to watsonxdemo application secrets
path "kv/data/watsonxdemo/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/metadata/watsonxdemo/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Admin access to group-specific secrets using group alias templating
# This allows admins to manage secrets for their group
path "kv/data/groups/{{identity.groups.names.vault-admins.metadata.name}}/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/metadata/groups/{{identity.groups.names.vault-admins.metadata.name}}/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow admins to manage configuration and shared secrets
path "kv/data/config/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/metadata/config/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
