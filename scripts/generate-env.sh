#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  echo ".env ya existe; no se sobrescribe."
  exit 0
fi

random_hex() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import secrets; print(secrets.token_hex(32))'
  else
    od -An -N32 -tx1 /dev/urandom | tr -d ' \n'
    printf '\n'
  fi
}

cat > .env <<EOF
BRUMA_DB_PASSWORD=$(random_hex)
BRUMA_AUTH_SECRET=$(random_hex)$(random_hex)
PULSO_APP_SECRET=$(random_hex)$(random_hex)
PULSO_DEMO_ADMIN_PASSWORD=$(random_hex)
EOF
chmod 600 .env
echo ".env creado con secretos aleatorios."
