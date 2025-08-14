#!/usr/bin/env bash
set -euo pipefail

# === Configuração ===
LOCATIONS=("freguesia1" "freguesia2" "freguesia3" "freguesia4" "freguesia5" "etc")
GEOJSON_URL="https://api.fogos.pt/v2/incidents/active?geojson=true"
SMS_API_URL="https://api.bulksms.com/v1/messages"
SMS_API_USER="xxxxxxxx"         # substitui com o teu user
SMS_API_PASS="xxxxxxxx"         # substitui com a tua pass
SMS_TO="+xxxxxxxx"          # número destino (com código internacional)
SMS_FROM="FogosAlert"           # opcional remetente

HIST_FILE="/tmp/fogos_alerts.log"

#!/usr/bin/env bash
set -euo pipefail


# === Funções ===
fetch_freguesias() {
  # 1. Baixa GeoJSON dos incidentes ativos
  # 2. Extrai todas as ocorrências "freguesia":"valor"
  curl -sSf "$GEOJSON_URL" | grep -oP '"freguesia"\s*:\s*"\K[^"]+'
}

check_fogo() {
  local freguesias="$1"
  local encontrados=()
  for loc in "${LOCATIONS[@]}"; do
    if echo "$freguesias" | grep -iq "^${loc}$"; then
      encontrados+=("$loc")
    fi
  done
  # Remove duplicados e retorna numa linha, separados por vírgulas
  printf "%s\n" "${encontrados[@]}" | sort -u | paste -sd ", " -
}

already_sent_today() {
  local loc="$1"
  local today
  today=$(date +%Y-%m-%d)
  grep -q "^${today}:${loc}$" "$HIST_FILE" 2>/dev/null
}

mark_sent_today() {
  local loc="$1"
  local today
  today=$(date +%Y-%m-%d)
  echo "${today}:${loc}" >> "$HIST_FILE"
}

send_sms() {
  local locations="$1"
  local message="Alerta: incendio(s) detetado(s) em ${locations}."
  curl -sSf --user "$SMS_API_USER:$SMS_API_PASS" \
    -H "Content-Type: application/json" \
    -X POST "$SMS_API_URL" \
    -d "{\"to\":\"$SMS_TO\",\"body\":\"$message\",\"from\":\"$SMS_FROM\"}"
}

# === Execução ===
freguesias=$(fetch_freguesias)
detected_list=$(check_fogo "$freguesias")

# Filtrar só as que ainda não receberam SMS hoje
to_alert=()
for loc in $detected_list; do
  if ! already_sent_today "$loc"; then
    to_alert+=("$loc")
  fi
done

if [[ ${#to_alert[@]} -gt 0 ]]; then
  # Construir string para SMS
  locations_str=$(printf "%s\n" "${to_alert[@]}" | paste -sd ", " -)
  echo "Incêndio(s) detetado(s) nas freguesias: $locations_str"
  send_sms "$locations_str" && echo "SMS enviada."

  # Marcar como enviadas
  for loc in "${to_alert[@]}"; do
    mark_sent_today "$loc"
  done
else
  echo "Sem novos incêndios para notificar hoje."
fi
