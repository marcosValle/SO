#!/bin/bash

function banner {
    if [[ $(dpkg -s figlet 1>/dev/null) -eq 1 ]]
    then
        apt install figlet
    fi

    echo LAB 1 | figlet
}

function formatResult {
    if [[ -z $1 ]]
    then
        echo "0"
    else
        echo "$1"
    fi
}

function plotCsv {
    gnuplot -p <<-EOR
        set terminal png enhanced font "Helvetica,20" size 1500,1500
        set autoscale
        set datafile separator ","
        set title "Syscalls por comando"
        set style data histogram
        set style histogram cluster gap 1
        set style fill solid
        set boxwidth 0.9
        set xtics format ""
        set grid ytics
        set output 'grafico.png'

        plot "grafico.csv" using 2:xtic(1) title "Rede", \
             '' using 3 title "Arquivo", \
             '' using 4 title "Memoria", \
             '' using 5 title "Total"
EOR

convert grafico.png grafico.pdf
rm grafico.png
}

if [[ $# -eq 0 ]]
then
    echo "Uso: $0 \"COMANDO1\" \"COMANDO2\" ..."
    echo "Exemplo: $0 \"ls /var/log\" \"ping -c 1 www.uol.com.br\" \"dig mx eb.mil.br\""
    exit
fi

banner 
>grafico.csv

listCmd=("$@")
for ((i = 0 ; i < ${#listCmd[@]} ; ++i))
do
    rede="$(formatResult $(strace -c -e trace=network ${listCmd[$i]}  2>&1 >/dev/null | awk 'END{print $3}'))"
    arquivo="$(formatResult $(strace -c -e trace=file ${listCmd[$i]}  2>&1 >/dev/null | awk 'END{print $3}'))"
    memoria="$(formatResult $(strace -c -e trace=memory ${listCmd[$i]}  2>&1 >/dev/null | awk 'END{print $3}'))"
    total="$(formatResult $(strace -c ${listCmd[$i]} 2>&1 >/dev/null | awk 'END{print $3}'))"

    echo "${listCmd[$i]}"
    echo "Rede: $rede"
    echo "Arquivo: $arquivo"
    echo "###################" 
    echo "${listCmd[$i]},$rede,$arquivo,$memoria,$total" >> grafico.csv
done
    plotCsv
    rm grafico.csv
