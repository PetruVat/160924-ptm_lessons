#!/bin/bash



read -p "Введите адрес для пинга (например, google.com): " target
target=${target:-"google.com"}


fail_count=0
max_failures=3
ping_threshold=100

echo "Начинаю пинговать $target. Контроль: время пинга > ${ping_threshold}мс или $max_failures неудач подряд."

while true; do
    ping_output=$(ping -c 1 $target 2>&1)

    if echo "$ping_output" | grep -q "time="; then
        time=$(echo "$ping_output" | grep -oP 'time=\K[0-9.]+')

        if (( $(echo "$time > $ping_threshold" | bc -l) )); then
            echo "⚠️  Время пинга $time мс превышает порог ${ping_threshold} мс"
        else
            echo "✅ Время пинга: $time мс (нормально)"
            fail_count=0
        fi
    else
        echo "❌ Не удалось выполнить пинг для $target"
        ((fail_count++))

        if [ $fail_count -ge $max_failures ]; then
            echo "⚠️ Адрес $target недоступен $max_failures раз подряд!"
        fi
    fi


    sleep 1
done
