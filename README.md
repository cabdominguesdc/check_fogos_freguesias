# check_fogos_freguesias
Script BASH que verifica se existem incêndios registados no fogos.pt (https://api.fogos.pt/v2/incidents/active?geojson=true) nas freguesias identificadas no parametro LOCATIONS  e envia SMS através do serviço [https://www.bulksms.com/a](https://api.bulksms.com/v1/messages) para o numero de telefone configurado no parametro SMS_TO

Parametros a configurar:

LOCATIONS=("Freguesia1" "Freguesia2" "Freguesia3" "Freguesia4" "etc")
SMS_API_USER="username_serviço_BULKSMS"         # substitui com o teu user
SMS_API_PASS="password_serviço_BULKSMS"         # substitui com a tua pass
SMS_TO="+351DESTINATARIO_SMS"          # número destino do SMS (com código internacional)
SMS_FROM="FogosAlert"           # opcional remetente, caso este ID esteja configurado no BULKSMS

é só dar permissões de execução ao script ex. chmod 755 script_deteta_fogos.sh e colocar no cron, de 3 em 3 minutos (ex.)

*/3 * * * * /home/ec2-user/script_deteta_fogos.sh


Nota: para evitar mandar SMS em excesso  (com incidntes repetidos), é criado um ficheiro temporario /tmp/fogos_alerts.log que gere o histórico. Este controlo é apenas diário.
