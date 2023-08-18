#!/bin/bash

# Función para manejar la señal SIGTSTP (Ctrl+Z)
cancel_input() {
    echo -e "\nOperación cancelada por Ctrl+Z"
    exit 1
}

# Establecer la función como manejador de la señal SIGTSTP
trap cancel_input SIGTSTP


# Mensaje de bienvenida
echo "Bienvenido a multi_bbmap, un script que funciona con conda,"
echo "que permite correr mapeos de referencia de varios archivos individualmente,"
echo "con la misma referencia, además de generar estadísticas básicas de cobertura"
echo "y permitir usar por completo todas las opciones de bbmap."

# Comprobar si Conda está configurado
if ! command -v conda &> /dev/null; then
    echo "Se requiere Conda para ejecutar este script. Instala Conda antes de continuar."
    exit 1
fi

# Activar el ambiente bbmap si existe
if conda info --envs | grep -q "^bbmap"; then
    echo "Activando el ambiente bbmap..."
    conda activate bbmap
else
    echo "El ambiente 'bbmap' no está creado. Crea un ambiente con ese nombre usando Conda antes de ejecutar este script."
    exit 1
fi

# Pedir al usuario que ingrese la carpeta de entrada
read -e -p "Ingresa la ruta de la carpeta con los archivos .fasta de entrada: " input_folder

# Comprobar si la carpeta de entrada existe
if [ ! -d "$input_folder" ]; then
    echo "La carpeta de entrada no existe."
    exit 1
fi

# Pedir al usuario que ingrese la ruta del archivo de referencia en .fasta
read -e -p "Ingresa la ruta del archivo de referencia en formato .fasta: " reference

# Comprobar si el archivo de referencia existe
if [ ! -f "$reference" ]; then
    echo "El archivo de referencia no existe."
    exit 1
fi

#Preguntar al usuario si quiere usar otras opciones de bbmap
read -p "¿Quieres usar otras opciones de bbmap? (Y/N): " use_other_options

# Si la respuesta es "Y" o "y"
if [[ "$use_other_options" =~ [Yy] ]]; then
    # Mostrar todas las opciones posibles de bbmap
    bbmap.sh
    echo "Coloca las opciones que deseas usar:"
    read bbmap_options
fi

# Pedir al usuario que ingrese la ruta de la carpeta para los archivos .tab de salida
read -e -p "Ingresa la ruta de la carpeta para los archivos .tab de salida: " output_folder

# Crear la carpeta de salida si no existe
if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi
# Procesar archivos de entrada
for input_file in "$input_folder"/*.fasta; do
    filename=$(basename "$input_file")
    filename_no_extension="${filename%.*}"
    output_subfolder="$output_folder/$filename_no_extension"
    
    # Crear la subcarpeta para cada input si no existe
    if [ ! -d "$output_subfolder" ]; then
        mkdir -p "$output_subfolder"
    fi
    
output_file="$output_subfolder/$filename_no_extension.sam"
    covstats_file="$output_subfolder/$filename_no_extension.covstats.tab"
    scafstats="$output_subfolder/$filename_no_extension.scafstats.tab"
    refstats="$output_subfolder/$filename_no_extension.refstats.tab"
    bhist="$output_subfolder/$filename_no_extension.bhist.tab"
    qhist="$output_subfolder/$filename_no_extension.qhist.tab"
    aqhist="$output_subfolder/$filename_no_extension.aqhist.tab"
    bqhist="$output_subfolder/$filename_no_extension.bqhist.tab"
    lhist="$output_subfolder/$filename_no_extension.lhist.tab"
    ihist="$output_subfolder/$filename_no_extension.ihist.tab"
    ehist="$output_subfolder/$filename_no_extension.ehist.tab"
    qahist="$output_subfolder/$filename_no_extension.qahist.tab"
    indelhist="$output_subfolder/$filename_no_extension.indelhist.tab"
    mhist="$output_subfolder/$filename_no_extension.mhist.tab"
    gchist="$output_subfolder/$filename_no_extension.gchist.tab"
    idhist="$output_subfolder/$filename_no_extension.idhist.tab"
    covhist="$output_subfolder/$filename_no_extension.covhist.tab"
    basecov="$output_subfolder/$filename_no_extension.basecov.tab"
    bincov="$output_subfolder/$filename_no_extension.bincov.tab"
    


 # Ejecutar bbmap con el archivo de entrada, referencia, opciones y archivo de salida correspondientes
    if [[ -n "$bbmap_options" ]]; then
        bbmap.sh ref="$reference" in="$input_file" out="$output_file" covstats="$covstats_file" scafstats="$scafstats" refstats="$refstats" bhist="$bhist" qhist="$qhist" aqhist="$aqhist" bqhist="$bqhist"	lhist="$lhist" ihist="$ihist" ehist="$ehist" qahist="$qahist" indelhist="$indelhist"	mhist="$mhist" gchist="$gchist" idhist="$idhist" covhist="$covhist" basecov="$basecov" bincov="$bincov" $bbmap_options
    else
        bbmap.sh ref="$reference" in="$input_file" out="$output_file" covstats="$covstats_file" scafstats="$scafstats" refstats="$refstats" bhist="$bhist" qhist="$qhist" aqhist="$aqhist" bqhist="$bqhist"	lhist="$lhist" ihist="$ihist" ehist="$ehist" qahist="$qahist" indelhist="$indelhist"	mhist="$mhist" gchist="$gchist" idhist="$idhist" covhist="$covhist" basecov="$basecov" bincov="$bincov"
    fi
    
    
    # Comprobar el estado de ejecución de bbmap
    if [ $? -eq 0 ]; then
        echo "Ejecución de bbmap para $filename completada exitosamente."
        
 if [ $? -eq 0 ]; then
            echo "Covstats para $filename creado exitosamente."
        else
            echo "El proceso de covstats no se completó con éxito para $filename."
        fi
    else
        echo "La ejecución de bbmap para $filename no se completó con éxito."
    fi
done

echo "Todos los archivos procesados."
