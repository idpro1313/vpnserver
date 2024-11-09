# Сервер VPN на Wireguard + WGDashboard
## Скрипт для чистой Ubuntu Server

#### Зайти на новый/свежеустановленный сервер и выполнить две команды в консоли:
-      sudo apt install git -y && git clone https://github.com/idpro1313/vpnserver.git
-      sudo sh ./vpnserver/install.sh
##  После завершения установки всех компонентов:
   
1. Portainer будет доступен по адресу `https://your_server_addr:9443/`

    Необходимо в течении 5 минут после установки зайти в Portainer и установить имя/пароль пользователя.

    Если не успели в течении 5 минут и получили сообщение "the Portainer instance timed out for security purposes...", выполните команды в консоли:

-       sudo docker stop portainer
-       sudo docker start portainer

2. Панель управления Wireguard будет доступна по адресу `http://your_server_addr:10086/`
   
      #### admin : admin
   
    В Панели управления в разделе "Settings" - "Peers Settings" изменить адрес "Peer Remote Endpoint" на IP адрес вашего сервера.
