#!/bin/bash

directories=$(ls -d */)

# Форматирование всех bash-скриптов
for d in $directories; do 
    shfmt -i 4 -s -w ${d}*.sh
    shfmt -i 4 -s -w ${d}func_tests/scripts/*.sh
    clang-format -style=Microsoft -i -Werror ${d}*.c
    clang-format -style=Microsoft -i -Werror ${d}*.h
done
