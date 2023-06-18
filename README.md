# docker-compose-zabbix-update-status
Script and zabbix template for monitoring docker container updates


1. Import template into your zabbix server and assign hosts
2. Script assumes you are using zabbix-agent (named zabbix-agent) docker container with $ZBX_SERVER_HOST and $ZBX_HOSTNAME set correctly
3. run script manually or with crontab
