# Policy for watsonxdemo AppRole authentication
# Tightened policy based on example_usage.py requirements
# Uses templating based on entity name for multi-tenant isolation

# Allow reading own token information (used by _log_token_info)
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow renewing own token (used by renew_token method)
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow listing mounted secret engines (used by _debug_available_mounts)
path "sys/mounts" {
    capabilities = ["read"]
}

# Allow checking capabilities (used by _debug_available_mounts)
path "sys/capabilities-self" {
    capabilities = ["update"]
}

# Allow listing secrets metadata at root level
path "kv/metadata" {
    capabilities = ["list"]
}

path "kv/data/watsonxdemo" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# KV-v2 secrets engine access using entity templating for tenant isolation
# Each entity can only access secrets under their own path
path "kv/data/{{identity.entity.name}}" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/data/{{identity.entity.name}}/*" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/metadata/{{identity.entity.name}}" {
    capabilities = ["read", "list", "delete"]
}

path "kv/metadata/{{identity.entity.name}}/*" {
    capabilities = ["read", "list", "delete"]
}


# KV-v1 fallback paths using entity templating (used by read_secret/write_secret attempts)
path "kv/{{identity.entity.name}}" {
    capabilities = ["create", "read", "update", "delete"]
}

path "kv/{{identity.entity.name}}/*" {
    capabilities = ["create", "read", "update", "delete"]
}

