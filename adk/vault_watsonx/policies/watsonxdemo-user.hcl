# Policy for watsonxdemo Regular Users (via Azure AD Vault-Users group)
# Application-focused policy using group templating

# Allow reading own token information
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow renewing own token
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Read-only access to watsonxdemo application secrets
path "kv/data/watsonxdemo/*" {
    capabilities = ["read"]
}

path "kv/metadata/watsonxdemo/*" {
    capabilities = ["read", "list"]
}

# Group-specific secrets using group alias templating
# Users can read/write secrets for their specific group
path "kv/data/groups/{{identity.groups.names.vault-users.metadata.name}}/*" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/metadata/groups/{{identity.groups.names.vault-users.metadata.name}}/*" {
    capabilities = ["read", "list", "delete"]
}

# Personal user workspace using user identity
path "kv/data/users/{{identity.entity.name}}/*" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/metadata/users/{{identity.entity.name}}/*" {
    capabilities = ["read", "list", "delete"]
}

# Read-only access to shared configuration
path "kv/data/config/*" {
    capabilities = ["read"]
}

path "kv/metadata/config/*" {
    capabilities = ["read", "list"]
}
