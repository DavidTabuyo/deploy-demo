# Deploy

Configuración común para ejecutar BRUMA, PULSO y NORTE detrás de un gateway Nginx.

Los tres proyectos deben estar disponibles como directorios hermanos de este repositorio: `bruma/`, `pulso/` y `norte/`.

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
