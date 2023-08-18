#!/bin/bash
 
echo "Bienvenido al script de análisis de múltiples genomas usando ABRICATE"
echo "Para ver las opciones disponibles, usa: $(basename "$0") -h"


# Comprobar si Conda está configurado
if ! command -v conda &> /dev/null; then
    echo "Se requiere Conda para ejecutar este script. Instala Conda antes de continuar."
    exit 1
fi

# Activar el ambiente AMR si existe
if conda info --envs | grep -q "^AMR"; then
    echo "Activando el ambiente AMR..."
    conda activate AMR
else
    echo "El ambiente 'AMR' no está creado. Crea un ambiente con ese nombre usando Conda antes de ejecutar este script."
    exit 1
fi


# Valores predeterminados (igual que antes)
input_folder="carpeta_de_genomas"
output_folder="resultados"
db="ncbi"
threads=8
abricate_opts=""



# Función de ayuda (modificada)
show_help() {
    echo "Uso: $(basename "$0") [-h] [-i input_folder] [-o output_folder] [--db database] [--threads num_threads] [--options] [opciones_abricate]"
    echo "Opciones:"
    echo "  -h                  Mostrar esta ayuda y las opciones de Abricate"
    echo "  -i input_folder     Carpeta de genomas de entrada (por defecto: carpeta_de_genomas)"
    echo "  -o output_folder    Carpeta de resultados de salida (por defecto: resultados)"
    echo "Ejemplo:"
    echo "  $(basename "$0") -i nueva_carpeta_de_genomas -o nueva_carpeta_de_resultados --db=vfdb --threads=4 --mincov=90 --minid=90"
    
    echo "Opciones de Abricate------------->"
    
    echo "
SYNOPSIS
  Find and collate amplicons in assembled contigs
AUTHOR
  Torsten Seemann (@torstenseemann)
USAGE
  % abricate --list
  % abricate [options] <contigs.{fasta,gbk,embl}[.gz] ...> > out.tab
  % abricate [options] --fofn fileOfFilenames.txt > out.tab
  % abricate --summary <out1.tab> <out2.tab> <out3.tab> ... > summary.tab
GENERAL
  --help          This help.
  --debug         Verbose debug output.
  --quiet         Quiet mode, no stderr output.
  --version       Print version and exit.
  --check         Check dependencies are installed.
  --threads [N]   Use this many BLAST+ threads [1].
  --fofn [X]      Run on files listed in this file [].
DATABASES
  --setupdb       Format all the BLAST databases.
  --list          List included databases.
  --datadir [X]   Databases folder [/home/isaias/anaconda3/envs/AMR/db].
  --db [X]        Database to use [ncbi].
OUTPUT
  --noheader      Suppress column header row.
  --csv           Output CSV instead of TSV.
  --nopath        Strip filename paths from FILE column.
FILTERING
  --minid [n.n]   Minimum DNA %identity [80].
  --mincov [n.n]  Minimum DNA %coverage [80].
MODE
  --summary       Summarize multiple reports into a table.
DOCUMENTATION
  https://github.com/tseemann/abricate
"	   
    exit 0
}


# Comprobar si falta alguna opción requerida
check_required_options() {
    if [ -z "$input_folder" ] || [ -z "$output_folder" ]; then
        show_help
    fi
}

# Procesar opciones de línea de comandos
while getopts ":hi:o:-:" opt; do
    case $opt in
        h)
            show_help
            ;;
        i)
            input_folder="$OPTARG"
            ;;
        o)
            output_folder="$OPTARG"
            ;;
        -)
            case $OPTARG in
                db)
                    db="$2"
                    shift 2
                    ;;
                threads)
                    threads="$2"
                    shift 2
                    ;;
                *)
                    # Pasar opciones desconocidas a Abricate
                    abricate_opts+="--$OPTARG "
                    shift
                    ;;
            esac
            ;;
        \?)
            echo "Opción inválida: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "La opción -$OPTARG requiere un argumento." >&2
            exit 1
            ;;
    esac
done

# Resto del script
mkdir -p "$output_folder"

for input_file in "$input_folder"/*.fasta; do
    output_file="$output_folder/$(basename "${input_file%.*}").tab"
    abricate --db "$db" --threads "$threads" $abricate_opts "$input_file" > "$output_file"
done


# Comprobar el estado de ejecución de Abricate
if [ $? -eq 0 ]; then
    echo "Análisis completado exitosamente."
else
    echo "El proceso no se completó con éxito."
fi
# Crear el resumen al final
abricate --summary "$output_folder"/*.tab > summary.tab

