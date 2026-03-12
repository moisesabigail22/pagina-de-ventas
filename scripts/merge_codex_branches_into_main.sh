#!/usr/bin/env bash
set -euo pipefail

# Mergea ramas remotas codex/* dentro de main preservando configuraciones y cambios.
# Uso:
#   bash scripts/merge_codex_branches_into_main.sh
# Variables opcionales:
#   REMOTE=origin
#   MAIN_BRANCH=main
#   PREFIX=codex/
#   PUSH_EACH=true|false
#   DELETE_MERGED=false|true

REMOTE="${REMOTE:-origin}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"
PREFIX="${PREFIX:-codex/}"
PUSH_EACH="${PUSH_EACH:-true}"
DELETE_MERGED="${DELETE_MERGED:-false}"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "❌ Este script debe ejecutarse dentro de un repositorio git."
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

cleanup() {
  git checkout "$CURRENT_BRANCH" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "===> Fetch de ramas remotas"
git fetch "$REMOTE" --prune

echo "===> Cambiando a $MAIN_BRANCH"
git checkout "$MAIN_BRANCH"
git pull --ff-only "$REMOTE" "$MAIN_BRANCH"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_BRANCH="backup/${MAIN_BRANCH}-before-merge-${TIMESTAMP}"
git branch "$BACKUP_BRANCH"
echo "✅ Backup creado: $BACKUP_BRANCH"

mapfile -t REMOTE_BRANCHES < <(git for-each-ref --format='%(refname:short)' "refs/remotes/${REMOTE}/${PREFIX}*")

if [ "${#REMOTE_BRANCHES[@]}" -eq 0 ]; then
  echo "⚠️ No se encontraron ramas ${REMOTE}/${PREFIX}*"
  exit 0
fi

echo "===> Ramas detectadas (${#REMOTE_BRANCHES[@]}):"
printf ' - %s\n' "${REMOTE_BRANCHES[@]}"

MERGED=()
CONFLICTS=()

for remote_branch in "${REMOTE_BRANCHES[@]}"; do
  local_branch="${remote_branch#${REMOTE}/}"

  # Saltar main por seguridad si coincide con prefijo raro
  if [ "$local_branch" = "$MAIN_BRANCH" ]; then
    continue
  fi

  echo ""
  echo "===> Mergeando: $remote_branch"
  if git merge --no-ff --no-edit "$remote_branch"; then
    MERGED+=("$local_branch")
    echo "✅ Merge OK: $local_branch"

    if [ "$PUSH_EACH" = "true" ]; then
      git push "$REMOTE" "$MAIN_BRANCH"
      echo "⬆️ Push realizado"
    fi
  else
    echo "❌ Conflicto en: $local_branch"
    CONFLICTS+=("$local_branch")
    git merge --abort || true
  fi
done

if [ "$PUSH_EACH" != "true" ] && [ "${#MERGED[@]}" -gt 0 ]; then
  git push "$REMOTE" "$MAIN_BRANCH"
  echo "⬆️ Push final realizado"
fi

if [ "$DELETE_MERGED" = "true" ] && [ "${#MERGED[@]}" -gt 0 ]; then
  echo "===> Borrando ramas remotas mergeadas"
  for b in "${MERGED[@]}"; do
    git push "$REMOTE" --delete "$b" || true
  done
fi

echo ""
echo "================ RESUMEN ================"
echo "✅ Mergeadas: ${#MERGED[@]}"
for b in "${MERGED[@]:-}"; do
  [ -n "$b" ] && echo "   - $b"
done

echo "❌ Con conflicto: ${#CONFLICTS[@]}"
for b in "${CONFLICTS[@]:-}"; do
  [ -n "$b" ] && echo "   - $b"
done

echo "📌 Backup branch: $BACKUP_BRANCH"
