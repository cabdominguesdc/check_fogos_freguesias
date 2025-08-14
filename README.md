# check_fogos_freguesias
Scriptque verifica se existem incêndios registados no fogos.pt (https://api.fogos.pt/v2/incidents/active?geojson=true) nas freguesias identificadas e envia SMS através do serviço [https://www.bulksms.com/a](https://api.bulksms.com/v1/messages)

Parametros a configurar:

LOCATIONS=("Brasfemes" "Penacova" "Souselas" "Eiras" "Redinha")

SMS_API_USER="username_serviço_BULKSMS"         # substitui com o teu user
SMS_API_PASS="password_serviço_BULKSMS"         # substitui com a tua pass
SMS_TO="+351DESTINATARIO_SMS"          # número destino do SMS (com código internacional)
SMS_FROM="FogosAlert"           # opcional remetente, caso este ID esteja configurado no BULKSMS
