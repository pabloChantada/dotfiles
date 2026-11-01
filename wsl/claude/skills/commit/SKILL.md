---
name: commit
description: Prepara y hace un commit con mensaje Conventional Commits a partir de los cambios actuales. Úsalo cuando el usuario escriba /commit.
disable-model-invocation: true
---

1. Ejecuta `git status` y `git diff --staged`. Si no hay nada en stage, enseña `git diff --stat` y pregunta qué añadir.
2. Si el proyecto tiene tests o ruff, ejecútalos rápido (`uv run ruff check .`, `uv run pytest -q`). Si fallan, avisa antes de seguir.
3. Propón un mensaje en inglés siguiendo Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`):
   - Resumen en imperativo, máximo 72 caracteres.
   - Cuerpo opcional explicando el porqué si el cambio no es obvio.
4. Si los cambios mezclan cosas no relacionadas, sugiere separarlos en varios commits.
5. Haz el commit cuando el usuario confirme. Nunca hagas push.
