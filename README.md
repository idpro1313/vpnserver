# Скрипт для чистой Ubuntu Server
1. Зайти на новый/свежеустановленный сервер
2. ```sudo apt install git -y```
5. ```git clone https://github.com/idpro1313/vpnserver.git```
7. ```cd vpnserver```
8. ```sudo sh install.sh```
9. Portainer будет доступен по адресу `https://your_server_addr:9443/`
10. Панель управления Wireguard будет доступна по адресу `http://your_server_addr:10086/`
11. В Панели управления в разделе "Settings" - "Peers Settings" изменить адрес "Peer Remote Endpoint" на IP адрес вашего сервера.
