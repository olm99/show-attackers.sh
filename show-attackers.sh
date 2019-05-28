#!/bin/bash

#Primer queremos tener un sitio donde guardar las IP's y su contador

declare -A contenedor #El -a se utiliza para que la variable sera tratada como array

#El siguiente paso es contar las IPS de cada fichero. Queremos las que sobrepasen los 10 intentos.

while read frase_linea; do #Aqui lee la IP que nos salga por pantalla

	if [[ ! -v "contenedor[$frase_linea]" ]]; then
		contenedor[$frase_linea]=1

	else
		contenedor[$frase_linea]=$((${contenedor[$frase_linea]}+1))

	fi

# Con /Failed/ le indicamos las frases y con NF indica la ultima posicion -3 seria la IP y el $1 lo ponemos para indicar de que fichero
done < <(awk '/Failed/ {printf "%s\n",$(NF-3)}' $1)

#Mostrar titulo (contador, IP, Localizaciom)
echo "Count, IP, Location"

for IP in "${!contenedor[@]}"; do #Aqui nos muestra todas las ips diferentes que hay y su contador en el contenedor.

	#Entonces una vez tenemos las IP miramos si el contador sobrepasa los 10 intentos.
	if [[ "contenedor[$IP]" -gt 10 ]]; then

		#Obtenemos la localizacion y la guardamos en la variable localizacion
		#Es importante usar en el awk estas comillas ' al inicio y al final, si no saltara error.
		localizacion=$(geoiplookup $IP | awk 'BEGIN{FS=","}{printf "%s\n",$2}')
		echo "${contenedor[$IP]},$IP,$localizacion"


	fi

#Para ordenar las IPs mirando el contador hacemos -Vr que sirve para ordenar numericamente 
done | sort -Vr
