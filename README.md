# Deploy

Configuración común para publicar BRUMA, PULSO, NORTE, OPOTEST y METAKANBAN detrás de un gateway Nginx.

Las aplicaciones dinámicas deben estar disponibles como directorios hermanos de este repositorio: `bruma/`, `pulso/`, `norte/` y `opotest-demo/`. Las demos autónomas se guardan bajo `gateway/static-demos/<slug>/` y se copian al construir el gateway.

## Uso local

Requiere Docker Engine y Docker Compose.

```bash
./scripts/generate-env.sh
docker compose up --build -d
./scripts/smoke-test.sh
```

El gateway queda disponible en `http://localhost:7575`. Para detener el entorno:

```bash
docker compose down
```

Las demos se publican en `/bruma/`, `/pulso/`, `/norte/`, `/opotest/` y `/metakanban/`.

## Demos estáticas

Cada demo estática vive en `gateway/static-demos/<slug>/index.html`. Para añadir una, incluye su ruta en Nginx, en la portada y en `scripts/smoke-test.sh`; después reconstruye únicamente el gateway. No necesita un servicio Compose independiente.

## Añadir o actualizar una demo

Consulta `AGENTS.md` para el procedimiento operativo, las comprobaciones y la forma de desplegar sin reiniciar Docker ni el túnel de Cloudflare.
