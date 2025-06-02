#!/usr/bin/env bash

while true; do
    echo "Требуется настройка сетевого интерфейса:"
    echo "[1] yes"
    echo "[2] no"
    read -p "Введите номер (1 или 2): " choice

    # Определяем необходимость установки
    case $choice in
        1)
            inter="yes"
            break
            ;;
        2)
            inter="no"
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done

# Определяем функции
function do_yes {
    while true; do
        echo "Укажите сетевой интерфейс:"
        echo "[1] eth0"
        echo "[2] ens192"
        read -p "Введите номер (1 или 2): " choice

        # Определяем значение сетевого интерфейса сервера
        case $choice in
            1)
                interfaces="eth0"
                read -p "Укажите ip-адрес: " ip
                read -p "Укажите netmask: " nm
                read -p "Укажите gateway: " gw
                read -p "Укажите dns: " ns
                break
                ;;
            2)
                interfaces="ens192"
                read -p "Укажите ip-адрес: " ip
                read -p "Укажите netmask: " nm
                read -p "Укажите gateway: " gw
                read -p "Укажите dns: " ns
                break
                ;;
            *)
                echo "Неверный выбор. Попробуйте снова."
                ;;
        esac
    done

    echo "Создаем файл конфигурации"
    cat > /etc/network/interfaces <<END
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo $interfaces
iface lo inet loopback
iface $interfaces inet static
address $ip
netmask $nm
gateway $gw
dns-domain ИМЯ СЕРВЕРА
dns-nameservers $ns
END

echo "Включаем сетевой интеррфейс ..."
    sudo ifconfig $interfaces up

    echo "Настройка сети завершена. Перезапуск сетевого интерфейса..."
    service networking  restart
}

function do_skip {
    echo "Вы выбрали пропустить настройку сетевого интерфейса."
}

# Вызываем соответствующую функцию
if [[ $inter == "yes" ]]; then
    do_yes
elif [[ $inter == "no" ]]; then
    do_skip
fi

clear
sleep 5
# Вывод содержимого конфигурационного файла
cat /etc/network/interfaces
sleep 5
clear

while true; do
    echo "Требуется настройка DNS и домена:"
    echo "[1] yes"
    echo "[2] no"
    read -p "Введите номер (1 или 2): " choice

    # Определяем необходимость установки
    case $choice in
        1)
            resol="yes"
            break
            ;;
        2)
            resol="no"
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done

# Определяем функции
function do_yes {
    echo "Укажите dns-сервера согласно локации:"
    read -p "Укажите dns_1: " ns1
    read -p "Укажите dns_2: " ns2
echo "Создаем файл конфигурации"
    cat > /etc/resolv.conf <<END
nameserver $ns1
nameserver $ns2
domain ИМЯ ВАШЕГО ДОМЕНА
END
}

function do_skip {
    echo "Вы выбрали пропустить настройку сетевого интерфейса."
}

# Вызываем соответствующую функцию
if [[ $resol == "yes" ]]; then
    do_yes
elif [[ $resol == "no" ]]; then
    do_skip
fi
clear
sleep 5
cat /etc/resolv.conf
sleep 5
clear

while true; do
    echo "Укажите, требуется установка VMWareTools:"
    echo "[1] yes"
    echo "[2] no"
    read -p "Введите номер (1 или 2): " choice

    # Определяем значение файлового менеджера
    case $choice in
        1)
            VMWareTools="yes"
            break
            ;;
        2)
            VMWareTools="no"
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done

function do_yes {
    apt install open-vm-tools
    sleep 5
    eject
}

function do_no {
    echo "Вы выбрали пропустить установку VMWareTools."
}

# Вызываем соответствующую функцию
if [[ $VMWareTools == "yes" ]]; then
    do_yes
elif [[ $VMWareTools == "no" ]]; then
    do_no
fi

while true; do
    echo "Выберите файловый менеджер операционной системы для установки KES:"
    echo "[1] apt"
    echo "[2] rpm"
    echo "[3] skip"
    read -p "Введите номер (1,2 или 3): " choice

    # Определяем значение файлового менеджера
    case $choice in
        1)
            distr="apt"
            break
            ;;
        2)
            distr="rpm"
            break
            ;;
        3)
            distr="skip"
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done

# Определяем функции
function do_apt {
    while true; do
    echo "Выберите сервер KSC:"
    echo "[1] IP KSC №1"
    echo "[2] IP KSC №2"
    read -p "Введите номер (1 или 2): " choice

    # Определяем значение сервера
    case $choice in
        1)
            SERVER="IP KSC №1"
            break
            ;;
        2)
            SERVER="IP KSC №2"
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done

echo "Создаем файл конфигурации и устанавливаем агента"
  apt install /tmp/kln* > /dev/null 2>&1
cat > /tmp/answer_kln.txt <<END
  EULA_ACCEPTED=1
  KLNAGENT_AUTOINSTALL=1
  KLNAGENT_SERVER=$SERVER
  KLNAGENT_PORT=14000
  KLNAGENT_SSLPORT=13000
  KLNAGENT_USESSL=Y
  KLNAGENT_GW_MODE=1
END

KLAUTOANSWERS=/tmp/answer_kln.txt /opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl > /dev/null 2>&1
clear
sleep 3
/opt/kaspersky/klnagent64/bin/klnagchk
sleep 5
clear

echo "Создаем файл конфигурации и устанавливаем KESL"
  apt install /tmp/kesl* > /dev/null 2>&1
cat > /tmp/answer_kesl.txt <<END
  KSVLA_MODE=no
  LOCALE=ru_RU.utf8
  EULA_AGREED=yes
  PRIVACY_POLICY_AGREED=yes
  USE_KSN=no
  UPDATER_SOURCE=SCServer
  INSTALL_LICENSE=none
  CONFIGURE_SELINUX=yes
  GROUP_CLEAN=No
#UPDATE_EXECUTE=yes
#KERNEL_SRCS_INSTALL=yes
END

/opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=/tmp/answer_kesl.txt > /dev/null 2>&1

sleep 3
systemctl status kesl.service --no-pager
sleep 5
clear
}

function do_rpm {
    while true; do
    echo "Выберите сервер KSC:"
    echo "[1] IP KSC №1"
    echo "[2] IP KSC №2"
    read -p "Введите номер (1 или 2): " choice

    # Определяем значение сервера
    case $choice in
        1)
            SERVER="IP KSC №1"
            break
            ;;
        2)
            SERVER="IP KSC №2"
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done

echo "Создаем файл конфигурации и устанавливаем агента"
rpm -i /tmp/kln* > /dev/null 2>&1
cat > /tmp/answer_kln.txt <<END
    EULA_ACCEPTED=1
    KLNAGENT_AUTOINSTALL=1
    KLNAGENT_SERVER=$SERVER
    KLNAGENT_PORT=14000
    KLNAGENT_SSLPORT=13000
    KLNAGENT_USESSL=Y
    KLNAGENT_GW_MODE=1
END

KLAUTOANSWERS=/tmp/answer_kln.txt /opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl > /dev/null 2>&1
clear
sleep 3
/opt/kaspersky/klnagent64/bin/klnagchk
sleep 5
clear

echo "Создаем файл конфигурации и устанавливаем KESL"
rpm -i /tmp/kesl* > /dev/null 2>&1
cat > /tmp/answer_kesl.txt <<END
    KSVLA_MODE=no
    LOCALE=ru_RU.utf8
    EULA_AGREED=yes
    PRIVACY_POLICY_AGREED=yes
    USE_KSN=no
    UPDATER_SOURCE=SCServer
    INSTALL_LICENSE=none
    CONFIGURE_SELINUX=yes
    GROUP_CLEAN=No
    #UPDATE_EXECUTE=yes
    #KERNEL_SRCS_INSTALL=yes
END

/opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=/tmp/answer_kesl.txt > /dev/null 2>&1

sleep 3
systemctl status kesl.service --no-pager
sleep 5
clear
}

function do_skip {
    echo "Вы выбрали пропустить установку KES."
}

# Вызываем соответствующую функцию
if [[ $distr == "apt" ]]; then
    do_apt
elif [[ $distr == "rpm" ]]; then
    do_rpm
elif [[ $distr == "skip" ]]; then
    do_skip
fi

sleep 2
/opt/kaspersky/klnagent64/bin/klnagchk #Проверка работы агента администрирования
sleep 10
clear
kesl-control --app-info #Вывод информации о KES
sleep 10

# Запрашиваем установку TMDS
while true; do
    echo "Укажите, требуется установка TMDS:"
    echo "[1] yes"
    echo "[2] no"
    read -p "Введите номер (1 или 2): " choice

    # Определяем значение TMDS
    case $choice in
        1)
            TMDS="yes"
            break
            ;;
        2)
            TMDS="no"
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done

# Функция для выбора файлового менеджера
function do_yes {
    while true; do
        echo "Укажите файловый менеджер ОС:"
        echo "[1] apt"
        echo "[2] rpm"
        read -p "Введите номер (1 или 2): " choice

        # Определяем значение файлового менеджера
        case $choice in
            1)
                FM="apt"
                break
                ;;
            2)
                FM="rpm"
                break
                ;;
            *)
                echo "Неверный выбор. Попробуйте снова."
                ;;
        esac
    done

    # Вызываем соответствующую функцию для установки
    if [[ $FM == "apt" ]]; then
        do_apt
    elif [[ $FM == "rpm" ]]; then
        do_rpm
    fi
}

function do_apt {
    dpkg -i /tmp/Agent*
}

function do_rpm {
    rpm -i /tmp/Agent*
}

function do_no {
    echo "Вы выбрали пропустить установку TMDS."
}

# Вызываем соответствующую функцию на основе выбора TMDS
if [[ $TMDS == "yes" ]]; then
    do_yes
elif [[ $TMDS == "no" ]]; then
    do_no
fi
sleep 10

echo "Объем оперативной памяти: "
    free -h | awk '/Mem:/ {print "Total Memory:", $2}'
    sleep 6
    echo "Info CPU: "
    lscpu 
    sleep 6
    echo "Объем дисков: "
    lsblk | grep '^sd'
    sleep 6
    clear


systemctl status systemctl status open-vm-tools --no-pager 
    sleep 5
    clear

systemctl status kesl.service --no-pager
    sleep 5
    clear

systemctl status ds_agent --no-pager
    sleep 5
    clear

history -c
sleep 3
