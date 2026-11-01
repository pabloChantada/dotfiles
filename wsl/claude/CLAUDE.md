# Instrucciones globales (Pablo)

## Comunicación
- Respóndeme en español, directo y conciso. Código, nombres de variables, comentarios y commits en inglés.
- Si algo es ambiguo o hay varias opciones razonables, pregunta antes de suponer.
- Para cambios que toquen varios archivos o la arquitectura, propón primero un plan breve.

## Entorno
- WSL2 (Ubuntu) con zsh. Los proyectos viven en el sistema de archivos de Linux (~/), no en /mnt/c.
- Python se gestiona con uv: `uv add`, `uv run`, `uv sync`. Nunca `pip install` global ni `sudo pip`.
- Herramientas disponibles: rg, fd, jq, gh, lazygit, ruff, pytest (vía uv).

## Estilo de código (Python)
- Type hints en funciones públicas. Docstrings breves solo donde aporten.
- ruff para lint y formato (se ejecuta automáticamente tras cada edición).
- pytest para tests. Si añades lógica no trivial, añade o actualiza tests.
- Prefiere soluciones simples y legibles a abstracciones prematuras.

## Flujo de trabajo
- Después de cambiar código, ejecuta los tests y linters relevantes y dime el resultado.
- No hagas commit ni push salvo que te lo pida. Usa /commit cuando lo pida.
- No leas ni modifiques archivos .env ni secretos.
- Si un comando falla, explica la causa antes de reintentar con otra cosa.
