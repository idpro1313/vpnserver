# Скрипт для чистой Ubuntu Server
1. Зайти на новый/свежеустановленный сервер
2. ```sudo apt install git -y```
5. ```git clone https://github.com/idpro1313/vpnserver.git```
7. ```cd vpnserver```
8. ```sudo sh install.sh```
9. Portainer будет доступен по адресу `https://your_server_addr:9443/`
10. Необходимо в течении 5 минут после установки зайти в Portainer и установить имя/пароль пользователя.
11. Если не успели в течении 5 минут и получили сообщение "the Portainer instance timed out for security purposes...", выполните команды в консоли:

    ```sudo docker stop portainer```

    ```docker start portainer```

14. Панель управления Wireguard будет доступна по адресу `http://your_server_addr:10086/`
15. В Панели управления в разделе "Settings" - "Peers Settings" изменить адрес "Peer Remote Endpoint" на IP адрес вашего сервера.
