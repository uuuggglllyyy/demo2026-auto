# demo2026-auto

Автоматизация демо-экзамена 09.02.06 Сетевое и системное администрирование
(КИМ 09.02.06-1-2027), вариант 1.

Скрипт запускается с HQ-CLI и по SSH настраивает остальные машины стенда
(HQ-RTR, BR-RTR, HQ-SRV, BR-SRV).

## Быстрый старт

### 1. На HQ-CLI — установка (один раз)

    bash <(curl -sL https://raw.githubusercontent.com/uuuggglllyyy/demo2026-auto/main/bootstrap.sh)

### 2. Настройка данных варианта

    cd ~/demo2026-auto
    cp inventory.yaml.example inventory.yaml
    nano inventory.yaml

### 3. Запуск

    ./deploy.sh              # все модули
    ./deploy.sh 00_common    # один модуль

## Структура

    demo2026-auto/
    ├── bootstrap.sh              # установка на HQ-CLI
    ├── deploy.sh                 # главный скрипт
    ├── inventory.yaml.example    # шаблон данных варианта
    ├── lib/
    │   ├── log.sh
    │   └── ssh.sh
    ├── modules/
    │   └── 00_common.sh          # FQDN, timezone, пользователи
    ├── templates/
    └── logs/
