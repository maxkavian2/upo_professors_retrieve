
#!/bin/bash

# style ----------------
declare -rx STYALERT="\e[1;31m"
declare -rx STYINFO="\e[1;36m"
declare -rx STYRES="\e[1;36m"
declare -rx STYEND="\e[0m"
declare -rx INFO="${STYINFO}[INFO]${STYEND}"
declare -rx ERROR="${STYALERT}[ERROR]${STYEND}"

# params -----------------
declare -r DEPARTMENT="departamento-biologia-molecular-e-ingenieria-bioquimica"
declare -r MAINPAGE="https://www.upo.es/<<DEPARTMENT>>/es/buscador-de-profesores/?buscadorprofesoresdepartamentofield-1=&numfield=1&searchaction=search&searchPage=<<REPLACE>>&submit=Buscar"
declare -r DEFPAGEN="1" # the minimum number of the pagination list
declare -r URLPREFIX="https://www.upo.es/profesorado/"
declare -r PROFFILE="professors"
declare -r RESULTSFILE="results"

# functions -----------

function makeurl (){
	echo "$1" | sed "s/<<REPLACE>>/$2/g" | sed "s/<<DEPARTMENT>>/$3/g"
}

function getprofdata (){
	HTM=$(curl -s  "${URLPREFIX}${1}")
	if [ "$?" -eq "1" ]; then
		echo -e "${ERROR} curl failure while retrieving ${1}. Exiting ..."
		exit 1
	fi
	SURNAME=$(echo "${HTM}" | grep -o -- "class=\"title\">[A-ZñÑ,\ \-]*<" | grep -o -- ">[A-ZñÑ,\ \-]*<" | grep -o -- "[A-ZñÑ\ ,\-]*" | cut -f1 -d, | xargs)
	NAME=$(echo "${HTM}" | grep -o -- "class=\"title\">[A-ZñÑ,\ \-]*<" | grep -o -- ">[A-ZñÑ,\ \-]*<" | grep -o -- "[A-ZñÑ\ ,\-]*" | cut -f2 -d, | xargs)
	AREA=$(echo "${HTM}" | xargs | grep -o "<dt>Área\ académica</dt>[\n\ ]*<dd>[A-Za-z\ ]*</dd>" | grep -o "dd>[A-Za-z0-9\ ]*</dd" | grep -o ">[A-Za-z0-9\ ]*<" | grep -o "[A-Za-z0-9\ ]*")
	CATEG=$(echo "${HTM}" | xargs | grep -o "<dt>Categoría docente</dt>[\n\ ]*<dd>[A-Za-z\ ]*</dd>" | grep -o "dd>[A-Za-z0-9\ ]*</dd" | grep -o ">[A-Za-z0-9\ ]*<" | grep -o "[A-Za-z0-9\ ]*")
	CORREO=$(echo "${HTM}" | xargs | grep -o "<dt>Correo electrónico</dt>[\n\ ]*<dd>[\.@A-Za-z\ ]*</dd>" | grep -o "dd>[\.@A-Za-z0-9\ ]*</dd" | grep -o ">[\.@A-Za-z0-9\ ]*<" | grep -o "[\.@A-Za-z0-9\ ]*")
	TLF=$(echo "${HTM}" | xargs | grep -o -- "<dt>Teléfono</dt>[\n\ ]*<dd>[0-9\ \-]*</dd>" | grep -o -- "dd>[0-9\ \-]*</dd" | grep -o -- ">[0-9\ \-]*<" | grep -o -- "[0-9\ \-]*" | sed "s/[-\ ]*//g")
	DESPACHO=$(echo "${HTM}" | xargs | grep -o -- "<dt>Despacho</dt>[\n\ ]*<dd>[a-zA-Z0-9\ \.\-]*</dd>" | grep -o -- "dd>[a-zA-Z0-9\ \.\-]*</dd" | grep -o -- ">[a-zA-Z0-9\ \.\-]*<" | grep -o -- "[a-zA-Z0-9\ \.\-]*")
	echo "\"${SURNAME}\"	\"${NAME}\"	\"${AREA}\"	\"${CATEG}\"	\"${CORREO}\" \"${TLF}\" \"${DESPACHO}\""
	sleep 1
}

# execution ---------------
echo -e "${STYINFO}info${STYEND}: getting number of pages from the default page ..."
MAINPAGE_N=$(makeurl "${MAINPAGE}" "${DEFPAGEN}" "${DEPARTMENT}")
declare -a PGNS=(`curl "${MAINPAGE_N}" | grep -o -- "data-numpag=\"[0-9]*\">[0-9]*<*" | grep -o ">[0-9]*<" | grep -o "[0-9]*"`)

echo -e "${STYINFO}info${STYEND}: retrieving professors list ..."

echo "" > "${PROFFILE}"
truncate -s 0 "${PROFFILE}"
for i in ${PGNS[*]}; do
	MAINPAGE_N=$(makeurl "${MAINPAGE}" "$i" "${DEPARTMENT}")
	curl "${MAINPAGE_N}" | grep -o "href[=\" /]*profesorado/[a-z]*/\"" | cut -f3 -d/ >> "${PROFFILE}"
done


echo "" > "${RESULTSFILE}"
truncate -s 0 "${RESULTSFILE}"
PROFS=()
readarray -d '' PROFS < <(cat "${PROFFILE}")
for P in ${PROFS[*]}; do
	#P="edelaar"
	echo -e "${STYINFO}info${STYEND}: getting information from ${STYINFO}${P}${STYEND} ..."
	getprofdata "${P}" >> "${RESULTSFILE}"
done



exit 0





