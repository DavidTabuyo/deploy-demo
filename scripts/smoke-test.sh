#!/usr/bin/env sh
set -eu
BASE_URL="${1:-http://127.0.0.1:7575}"

check() {
  path="$1"
  printf '%-32s' "$path"
  code="$(curl -ksS -o /dev/null -w '%{http_code}' "$BASE_URL$path")"
  case "$code" in
    200|301|302|303|307|308) echo " OK ($code)" ;;
    *) echo " FAIL ($code)"; exit 1 ;;
  esac
}

check "/"
check "/bruma/"
check "/bruma/cafe"
check "/bruma/admin"
check "/bruma/api/health"
check "/pulso/"
check "/pulso/servicios"
check "/pulso/reservar"
check "/pulso/panel/login"
check "/pulso/health"
check "/norte/"
check "/norte/proyectos/"
check "/norte/contacto/"
check "/opotest/"
check "/opotest/health"
check "/metakanban/"

echo "Smoke test completado."
