# Deploy

Configuración común para ejecutar BRUMA, PULSO, NORTE y OPOTEST detrás de un gateway Nginx.

Los cuatro proyectos deben estar disponibles como directorios hermanos de este repositorio: `bruma/`, `pulso/`, `norte/` y `opotest-demo/`.

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

Las demos se publican en `/bruma/`, `/pulso/`, `/norte/` y `/opotest/`.

## Añadir o actualizar una demo

Consulta `AGENTS.md` para el procedimiento operativo, las comprobaciones y la forma de desplegar sin reiniciar Docker ni el túnel de Cloudflare.
