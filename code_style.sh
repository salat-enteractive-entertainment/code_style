#!/bin/bash

set -e 

help_text() {
    echo "Использование: $0 [опции] [аргументы]"
    echo "Флаги:"
    echo "  -h, --help    Показать справку"
    echo "  -t, --type    Указать формат форматируемых файлов"
    echo "               Доступные форматы: c, sh, h"
    echo "  -f, --file    Указать конкретный файл для форматирования"
    echo "  -d, --dir     Указать директорию для рекурсивного форматирования"
}

file=""
directory=""
file_type=""

while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help)
            help_text
            exit
            ;;
        -t | --type)
            shift; 
            if [[ -z "$1" ]]; then
                exit 2
            fi
            file_type=$1
            ;;
        -f | --file)
            shift;
            if [[ -z "$1" ]]; then
                exit 3
            fi
            file=$1
            ;;
        -d | --dir)
            shift;
            if [[ -z "$1" ]]; then
                exit 4
            fi
            directory=$1
            ;;
        *)
            echo "Неверный флаг: $1"
            exit 5
            ;;
    esac
    shift
done

shell_files=""
c_files=""
h_files=""

if [[ "$file_type" = "" ]]; then
    shell_files=$(find . -name "*.sh")
    c_files=$(find . -name "*.c")
    h_files=$(find . -name "*.h")
elif [[ "$file_type" = "h" ]]; then
    h_files=$(find . -name "*.h")
elif [[ "$file_type" = "c" ]]; then
    c_files=$(find . -name "*.c")
elif [[ "$file_type" = "sh" ]]; then
    shell_files=$(find . -name "*.sh")
else
    exit 6
fi

for file in $shell_files; do
    shfmt -i 4 -s -w "${file}"
done

for file in $c_files; do
    clang-format -style=Microsoft -i -Werror "${file}"
done

for file in $h_files; do
    clang-format -style=Microsoft -i -Werror "${file}"
done
