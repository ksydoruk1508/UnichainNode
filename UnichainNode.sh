#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета (сброс цвета)

# Логотип (можно заменить на твой)
channel_logo() {
    echo -e "${GREEN}"
    cat << "EOF"
██    ██ ███    ██ ██  ██████ ██   ██  █████  ██ ███    ██ ███    ██  ██████  ██████  ███████                                           
██    ██ ████   ██ ██ ██      ██   ██ ██   ██ ██ ████   ██ ████   ██ ██    ██ ██   ██ ██                                                
██    ██ ██ ██  ██ ██ ██      ███████ ███████ ██ ██ ██  ██ ██ ██  ██ ██    ██ ██   ██ █████                                             
██    ██ ██  ██ ██ ██ ██      ██   ██ ██   ██ ██ ██  ██ ██ ██  ██ ██ ██    ██ ██   ██ ██                                                
 ██████  ██   ████ ██  ██████ ██   ██ ██   ██ ██ ██   ████ ██   ████  ██████  ██████  ███████                                           
                                                                                                                                        
________________________________________________________________________________________________________________________________________                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                        
███████  ██████  ██████      ██   ██ ███████ ███████ ██████      ██ ████████     ████████ ██████   █████  ██████  ██ ███    ██  ██████  
██      ██    ██ ██   ██     ██  ██  ██      ██      ██   ██     ██    ██           ██    ██   ██ ██   ██ ██   ██ ██ ████   ██ ██       
█████   ██    ██ ██████      █████   █████   █████   ██████      ██    ██           ██    ██████  ███████ ██   ██ ██ ██ ██  ██ ██   ███ 
██      ██    ██ ██   ██     ██  ██  ██      ██      ██          ██    ██           ██    ██   ██ ██   ██ ██   ██ ██ ██  ██ ██ ██    ██ 
██       ██████  ██   ██     ██   ██ ███████ ███████ ██          ██    ██           ██    ██   ██ ██   ██ ██████  ██ ██   ████  ██████  
                                                                                                                                        
                                                                                                                                        
 ██  ██████ ██       █████  ███    ██ ██████   █████  ███    ██ ████████ ███████                                                        
██  ██       ██     ██   ██ ████   ██ ██   ██ ██   ██ ████   ██    ██    ██                                                             
██  ██       ██     ███████ ██ ██  ██ ██   ██ ███████ ██ ██  ██    ██    █████                                                          
██  ██       ██     ██   ██ ██  ██ ██ ██   ██ ██   ██ ██  ██ ██    ██    ██                                                             
 ██  ██████ ██      ██   ██ ██   ████ ██████  ██   ██ ██   ████    ██    ███████                                                        
                                                                                                                                        
                                                                                                                                        
EOF
    echo -e "${NC}"
}

download_node() {
    echo -e "${BLUE}Начинается установка ноды Unichain...${NC}"

    # Обновление и установка зависимостей
    echo -e "${BLUE}Обновляем и устанавливаем необходимые пакеты...${NC}"
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install make build-essential unzip lz4 gcc git jq -y

    # Установка Docker
    echo -e "${BLUE}Устанавливаем Docker...${NC}"
    sudo apt install docker.io -y

    # Запуск и активация Docker
    echo -e "${BLUE}Запускаем и включаем Docker...${NC}"
    sudo systemctl start docker
    sudo systemctl enable docker

    # Установка Docker Compose
    echo -e "${BLUE}Устанавливаем Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Клонирование репозитория
    echo -e "${BLUE}Клонируем репозиторий Unichain...${NC}"
    git clone https://github.com/Uniswap/unichain-node
    cd unichain-node || { echo -e "${RED}Не удалось перейти в директорию unichain-node. Выход...${NC}"; return; }

    # Настройка docker-compose.yml
    echo -e "${BLUE}Настраиваем docker-compose.yml для использования .env.mainnet...${NC}"
    sed -i '/^[[:space:]]*#.*\.env\.mainnet/s/^[[:space:]]*#/ /' docker-compose.yml

    # Запуск ноды
    echo -e "${BLUE}Запускаем ноду через Docker Compose...${NC}"
    sudo docker-compose up -d

    echo -e "${GREEN}Нода Unichain успешно установлена и запущена!${NC}"
}

restart_node() {
    echo -e "${BLUE}Перезапускаем ноду Unichain...${NC}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d

    echo -e "${GREEN}Нода Unichain успешно перезапущена!${NC}"
}

check_node() {
    echo -e "${BLUE}Проверяем статус ноды Unichain...${NC}"
    response=$(curl -s -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
        -H "Content-Type: application/json" http://localhost:8545)

    if [ -z "$response" ]; then
        echo -e "${RED}Не удалось получить ответ от ноды. Убедитесь, что она запущена и доступна на порту 8545.${NC}"
    else
        echo -e "${CYAN}Ответ ноды:${NC} $response"
    fi
    echo -e "${BLUE}Проверка завершена.${NC}"
}

check_logs_op_node() {
    echo -e "${BLUE}Показываем последние 300 строк логов контейнера unichain-node-op-node-1...${NC}"
    sudo docker logs unichain-node-op-node-1 --tail 300
    echo -e "${BLUE}Просмотр логов завершен. Возвращаемся в главное меню...${NC}"
}

check_logs_unichain() {
    echo -e "${BLUE}Показываем последние 300 строк логов контейнера unichain-node-execution-client-1...${NC}"
    sudo docker logs unichain-node-execution-client-1 --tail 300
    echo -e "${BLUE}Просмотр логов завершен. Возвращаемся в главное меню...${NC}"
}

stop_node() {
    echo -e "${BLUE}Останавливаем ноду Unichain...${NC}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    echo -e "${GREEN}Нода Unichain успешно остановлена!${NC}"
}

update_node() {
    echo -e "${BLUE}Обновляем ноду Unichain...${NC}"
    cd $HOME

    # Остановка текущих контейнеров
    HOMEDIR="$HOME"
    echo -e "${BLUE}Останавливаем текущие контейнеры...${NC}"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down

    # Поиск контейнеров
    op_node_container=$(docker ps -a --filter "name=op-node" --format "{{.ID}}")
    op_geth_container=$(docker ps -a --filter "name=op-geth" --format "{{.ID}}")

    if [ -n "$op_node_container" ]; then
        echo -e "${BLUE}Останавливаем и удаляем контейнер op-node...${NC}"
        docker stop "$op_node_container"
        docker rm "$op_node_container"
    fi

    if [ -n "$op_geth_container" ]; then
        echo -e "${BLUE}Останавливаем и удаляем контейнер op-geth...${NC}"
        docker stop "$op_geth_container"
        docker rm "$op_geth_container"
    fi

    # Сохранение приватных ключей
    echo -e "${BLUE}Сохраняем приватные ключи...${NC}"
    P2P_PRIV_KEY=$(cat $HOME/unichain-node/opnode-data/opnode_p2p_priv.txt 2>/dev/null || echo "")
    GETH_PRIV_KEY=$(cat $HOME/unichain-node/geth-data/geth/nodekey 2>/dev/null || echo "")

    if [ -z "$P2P_PRIV_KEY" ] || [ -z "$GETH_PRIV_KEY" ]; then
        echo -e "${RED}Один из приватных ключей не найден. Убедитесь, что файлы существуют. Выход...${NC}"
        exit 1
    else
        echo -e "${GREEN}Приватные ключи успешно сохранены. Продолжаем...${NC}"
    fi

    # Удаление старой версии и клонирование новой
    echo -e "${BLUE}Удаляем старую версию и клонируем новую...${NC}"
    sudo rm -rf unichain-node/
    git clone https://github.com/Uniswap/unichain-node

    cd unichain-node || { echo -e "${RED}Не удалось перейти в директорию unichain-node. Выход...${NC}"; return; }

    # Настройка docker-compose.yml
    echo -e "${BLUE}Настраиваем docker-compose.yml для использования .env.mainnet...${NC}"
    sed -i '/^[[:space:]]*#.*\.env\.mainnet/s/^[[:space:]]*#/ /' docker-compose.yml

    # Восстановление приватных ключей
    echo -e "${BLUE}Восстанавливаем приватные ключи...${NC}"
    mkdir -p opnode-data
    cd opnode-data
    echo $P2P_PRIV_KEY > opnode_p2p_priv.txt

    cd $HOME/unichain-node
    mkdir -p geth-data/geth
    cd geth-data/geth
    echo $GETH_PRIV_KEY > nodekey

    cd $HOME/unichain-node

    # Запуск ноды
    echo -e "${BLUE}Запускаем обновлённую ноду...${NC}"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d

    echo -e "${GREEN}Нода Unichain успешно обновлена и запущена!${NC}"
}

display_private_key() {
    echo -e "${BLUE}Отображаем приватные ключи...${NC}"
    cd $HOME
    if [ -f unichain-node/geth-data/geth/nodekey ]; then
        echo -e "${CYAN}Ваш приватный ключ GETH:${NC}"
        cat unichain-node/geth-data/geth/nodekey
    else
        echo -e "${RED}Приватный ключ GETH не найден!${NC}"
    fi
    if [ -f unichain-node/opnode-data/opnode_p2p_priv.txt ]; then
        echo -e "${CYAN}Ваш приватный ключ OP-NODE:${NC}"
        cat unichain-node/opnode-data/opnode_p2p_priv.txt
    else
        echo -e "${RED}Приватный ключ OP-NODE не найден!${NC}"
    fi
    echo -e "${BLUE}Отображение ключей завершено.${NC}"
}

delete_node() {
    echo -e "${YELLOW}Если уверены, что хотите удалить ноду, введите любую букву (CTRL+C чтобы выйти):${NC}"
    read -p "> " checkjust

    echo -e "${BLUE}Останавливаем ноду Unichain...${NC}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down

    # Удаление контейнеров
    echo -e "${BLUE}Удаляем контейнеры Unichain...${NC}"
    op_node_container=$(docker ps -a --filter "name=op-node" --format "{{.ID}}")
    op_geth_container=$(docker ps -a --filter "name=op-geth" --format "{{.ID}}")

    if [ -n "$op_node_container" ]; then
        docker stop "$op_node_container"
        docker rm "$op_node_container"
        echo -e "${GREEN}Контейнер op-node удалён.${NC}"
    fi

    if [ -n "$op_geth_container" ]; then
        docker stop "$op_geth_container"
        docker rm "$op_geth_container"
        echo -e "${GREEN}Контейнер op-geth удалён.${NC}"
    fi

    # Удаление директории unichain-node
    echo -e "${BLUE}Удаляем директорию unichain-node...${NC}"
    sudo rm -rf $HOME/unichain-node
    echo -e "${GREEN}Директория unichain-node удалена.${NC}"

    # Удаление Docker-образов
    echo -e "${BLUE}Удаляем Docker-образы Unichain...${NC}"
    docker images -a | grep "unichain" | awk '{print $3}' | xargs -r docker rmi -f
    echo -e "${GREEN}Docker-образы Unichain удалены.${NC}"

    echo -e "${GREEN}Нода Unichain полностью удалена!${NC}"
}

exit_from_script() {
    echo -e "${BLUE}Выход из скрипта...${NC}"
    exit 0
}

main_menu() {
    while true; do
        channel_logo
        sleep 2
        echo -e "\n\n${YELLOW}Выберите действие:${NC}"
        echo -e "${CYAN}1. Установить ноду${NC}"
        echo -e "${CYAN}2. Перезапустить ноду${NC}"
        echo -e "${CYAN}3. Проверить статус ноды${NC}"
        echo -e "${CYAN}4. Просмотреть логи Unichain (OP)${NC}"
        echo -e "${CYAN}5. Просмотреть логи Unichain (Execution Client)${NC}"
        echo -e "${CYAN}6. Остановить ноду${NC}"
        echo -e "${CYAN}7. Обновить ноду${NC}"
        echo -e "${CYAN}8. Показать приватные ключи${NC}"
        echo -e "${CYAN}9. Удалить ноду${NC}"
        echo -e "${CYAN}10. Выход${NC}"
        
        echo -e "${YELLOW}Введите номер:${NC} "
        read choice
        case $choice in
            1) download_node ;;
            2) restart_node ;;
            3) check_node ;;
            4) check_logs_op_node ;;
            5) check_logs_unichain ;;
            6) stop_node ;;
            7) update_node ;;
            8) display_private_key ;;
            9) delete_node ;;
            10) exit_from_script ;;
            *) echo -e "${RED}Неверный выбор, попробуйте снова.${NC}" ;;
        esac
    done
}

main_menu
