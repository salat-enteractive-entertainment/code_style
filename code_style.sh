#!/bin/bash

set -e

help_text() {
    echo "Использование: $0 [опции] [аргументы]"
    echo "Флаги:"
    echo "  -h, --help    Показать справку"
    echo "  -t, --type    Указать формат форматируемых файлов"
    echo "                Доступные форматы: c, sh, h"
    echo "  -f, --file    Указать конкретный файл для форматирования"
}

file=""
file_type=""

while [[ $1 != "" ]]; do
    case $1 in
    -h | --help)
        help_text
        exit 0
        ;;
    -t | --type)
        shift
        if [[ -z $1 ]]; then
            echo "Ошибка: отсутствует значение для -t [--type]"
            exit 2
        fi
        file_type=$1
        ;;
    -f | --file)
        shift
        if [[ -z $1 ]]; then
            echo "Ошибка: отсутствует значение для -f [--file]"
            exit 3
        fi
        file=$1
        ;;
    *)
        echo "Неверный флаг: $1"
        exit 5
        ;;
    esac
    shift
done

process_files() {
    local type=$1
    local files=()

    case $type in
    h)
        while IFS= read -r file -d ''; do
            files+=("$file")
        done < <(find . -type f -name "*.h" -print0)
        ;;
    c)
        while IFS= read -r file -d ''; do
            files+=("$file")
        done < <(find . -type f -name "*.c" -print0)
        ;;
    sh)
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find . -type f -name "*.sh" -print0)
        ;;
    esac
    for obj in "${files[@]}"; do
        case $type in
        h | c)
            clang-format -style=Microsoft -i -Werror "$obj"
            ;;
        sh)
            shfmt -i 4 -s -w "$obj"
            ;;
        esac
    done
}

if [[ -n $file ]]; then
    if [[ $file == *.h || $file == *.c ]]; then
        clang-format -style=Microsoft -i -Werror "$file"
    elif [[ $file == *.sh ]]; then
        shfmt -i 4 -s -w "$file"
    else
        echo "Ошибка: неизвестный тип файла"
        exit 1
    fi
    exit
fi

if [[ -z $file_type ]]; then
    process_files h
    process_files c
    process_files sh
else
    case $file_type in
    h | c | sh)
        process_files "$file_type"
        ;;
    *)
        echo "Ошибка: неверный тип файла"
        exit 6
        ;;
    esac
fi
