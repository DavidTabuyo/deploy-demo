# Operación del entorno de demos

Este repositorio orquesta las demos publicadas en `https://demo.solucionfacil.es`. Los repositorios de aplicación deben estar como directorios hermanos de `deploy/`.

## Arquitectura

- Docker Compose usa el nombre de proyecto `demo-solucionfacil`.
- El gateway Nginx publica exclusivamente `127.0.0.1:7575`.
- `cloudflared.service` expone ese gateway en el dominio público. Las rutas de cada demo se resuelven en Nginx, no en Cloudflare.
- Los contenedores usan `restart: unless-stopped`, por lo que vuelven a arrancar con Docker tras reiniciar el servidor.
- No existe ni hace falta un servicio systemd independiente para cada demo.
- No se debe reiniciar Docker ni `cloudflared` para añadir o actualizar una demo.

Servicios actuales:

| Ruta | Servicio Compose | Puerto interno | Tratamiento del prefijo |
| --- | --- | --- | --- |
| `/bruma/` | `bruma` | 3000 | Se conserva; Next.js conoce `basePath=/bruma` |
| `/pulso/` | `pulso` | 8000 | Nginx elimina `/pulso` |
| `/norte/` | `norte` | 80 | Nginx elimina `/norte` |
| `/opotest/` | `opotest` | 8000 | Nginx elimina `/opotest`; la app genera URLs con ese prefijo |
| `/metakanban/` | estático en `gateway` | — | Se sirve directamente desde `gateway/static-demos/metakanban/` |

BRUMA usa PostgreSQL y los demás servicios gestionan su persistencia según su propio Compose. OpoTest conserva la SQLite plantilla en `opotest_data`; cada visitante trabaja sobre una copia temporal aislada.

## Integrar una demo nueva

1. Clonar el repositorio como hermano de `deploy/` y confirmar que el árbol Git está limpio.
2. Leer su README, Dockerfile, Compose, healthcheck, puerto interno, ruta base, persistencia y variables necesarias.
3. Construir y probar la demo de forma aislada antes de conectarla al gateway.
4. Añadir el servicio a `docker-compose.yml` con `restart: unless-stopped`, la red `frontend`, volumen si procede y un healthcheck.
5. Añadirlo a `gateway.depends_on` con `condition: service_healthy`.
6. Añadir el `upstream` y los bloques `location` en `gateway/nginx.conf`. Decidir explícitamente si el prefijo se conserva o se elimina según cómo genere URLs la aplicación.
7. Añadir la ruta a la expresión final que devuelve 404 para rutas desconocidas.
8. Añadir una tarjeta en `gateway/index.html` y adaptar la cuadrícula si cambia el número de demos.
9. Añadir al menos portada y healthcheck a `scripts/smoke-test.sh`.
10. Actualizar README y este documento si cambia la arquitectura.

No ejecutar el Compose independiente de una demo para publicarla: Cloudflare solo alcanza el gateway común del puerto 7575.

### Integrar una demo estática

1. Crear `gateway/static-demos/<slug>/index.html` y colocar allí sus recursos relativos.
2. Añadir una ruta explícita en `gateway/nginx.conf` y permitir el slug en la expresión final de rutas conocidas.
3. Añadir su tarjeta a `gateway/index.html` y su portada a `scripts/smoke-test.sh`.
4. Actualizar README y esta tabla.
5. Reconstruir y recrear únicamente `gateway`; una demo estática no necesita servicio Compose ni healthcheck propio.

## Validación y despliegue

Desde `deploy/`:

```bash
docker compose config --quiet
docker compose build <servicio> gateway
docker compose up -d --no-deps <servicio>
docker compose ps
docker compose up -d --no-deps gateway
docker compose ps
./scripts/smoke-test.sh
./scripts/smoke-test.sh https://demo.solucionfacil.es
```

Esperar a que el servicio nuevo aparezca como `healthy` antes de recrear el gateway. Es importante usar `--no-deps`: `docker compose up -d --build <servicio> gateway` también puede reconstruir y recrear todos los servicios declarados como dependencias de `gateway`. La recreación del gateway puede producir una interrupción de pocos segundos. No usar `docker compose down` para una actualización normal.

Después del despliegue:

- comprobar que el servicio y el gateway están `healthy`;
- comprobar la URL local mediante `http://127.0.0.1:7575/<ruta>/`;
- comprobar la misma ruta en el dominio público;
- revisar logs solo si falla: `docker compose logs --tail=200 <servicio> gateway`;
- confirmar que las demos anteriores continúan respondiendo.

## Actualizaciones y recuperación

- Para actualizar una sola demo después de hacer `git pull` en su repositorio: `docker compose build <servicio> && docker compose up -d --no-deps <servicio>`.
- Si cambia la configuración de Nginx o la portada: construir `gateway` y ejecutar `docker compose up -d --no-deps gateway` cuando la demo nueva ya esté saludable.
- Para volver a la versión anterior, restaurar el commit anterior del repositorio afectado y reconstruir solo ese servicio.
- No eliminar volúmenes salvo que se haya confirmado que los datos se pueden regenerar. `docker compose down -v` es destructivo.

## Seguridad y Git

- Nunca mostrar ni registrar el contenido de `deploy/.env` o el token de `cloudflared`.
- `deploy/.env` debe conservar permisos `600` y no se versiona.
- Para comprobar el túnel basta con consultar su estado; no imprimir el `ExecStart`, porque contiene una credencial.
- No introducir secretos en Compose, Dockerfiles, README, AGENTS ni commits.
- Los commits de mantenimiento solicitados por el propietario se firman como `dariomm2 <dariommsr71@gmail.com>`.
- Antes de hacer commit: revisar `git diff --check`, `git diff`, el estado de Compose y los smoke tests local y público.
