#!/bin/bash

function filtra_ip {
	egrep -o '([0-9]{1,3}\.){3}([0-9]{1,3})' log_apache | sort -u | egrep -v '6' | tee inter1
}

function faz_whois {
	for ip in $(cat inter1 | head -n 2)
	do
		case $(whois $ip | grep $1 | awk '{print $2}' 2>/dev/null) in
			BZ ) ;;
			TH ) ;;
			GE ) ;;
			DE ) ;;
			* )
				echo "O endereço $ip é uma AMEAÇA"
		esac

	done
}

function procura {
	echo "Digite A1 para procura com grep simples"
	echo "Digite A2 para procura com egrep + expressões regulares"

	read op

	case $op in
		A1 )
			echo "Digite a palavra a ser procurada"
			read palavra
			grep $palavra log_apache
			;;
		A2 )
			echo "Digite a expressão regular a ser procurada"
			read palavra
			egrep $palavra log_apache
			;;
		*)
			echo "opção inválida"
			;;
	esac
}

function busca {
	
}

#filtra_ip
#faz_whois country
procura
