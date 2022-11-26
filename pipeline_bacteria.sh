#para correr este script se tiene que usar el comando (bash -i pipeline_bacteria.sh) (to run this script you have tu run the command (bash -i pipeline_bacteria.sh))
conda activate fastqc
fastqc /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/20k_R1.fastq.gz /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/20k_R2.fastq.gz
conda deactivate
java -jar /home/lab/Downloads/Trimmomatic-0.39/trimmomatic-0.39.jar PE /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/*_R1.fastq.gz /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/*_R2.fastq.gz 20k_forward_paired.fq.gz 20k_forward_unpaired.fq.gz 20k_reverse_paired.fq.gz 20k_reverse_unpaired.fq.gz ILLUMINACLIP:/home/lab/Downloads/Trimmomatic-0.39/NexteraPE-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36
conda activate fastqc
fastqc *_forward_paired.fq.gz *_reverse_paired.fq.gz
conda deactivate
conda activate multiqc
multiqc .
conda deactivate
conda activate unicycler
unicycler -1 *_forward_paired.fq.gz -2 *_reverse_paired.fq.gz -o Assembly -t 32 --min_fasta_length 200
conda deactivate
conda activate bbmap
bbmap.sh ref=/media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/K.michiganensis_refseq.fasta in=20k_forward_paired.fq.gz in2=20k_reverse_paired.fq.gz covstats=reads_bbmap_covstats.txt covhist=reads_bbmap_covhist.txt basecov=reads_bbmap_basecov.txt outu=reads_unmapped.fastq out=reads_ref.bam 
bbmap.sh ref=/media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/K.michiganensis_refseq.fasta in=/media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/20K_michiganensis/assembly.fasta covstats=assembly_covstats.txt covhist=assembly_covhist.txt basecov=assembly_basecov.txt outu=assembly_unmapped.fastq out=assembly.bam
conda deactivate
conda activate quast
quast /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/Assembly/assembly.fasta
conda deactivate
conda activate AMR
abricate --threads 32 --db ncbi /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/Assembly/assembly.fasta > resistance.tab
abricate --threads 32 --db vfdb /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/Assembly/assembly.fasta > vfdb.tab
abricate --threads 32 --db plasmidfinder /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/Assembly/assembly.fasta > plasmidfinder.tab
conda deactivate
conda activate prokka
prokka /media/lab/Disco_3/kp_fasta/fastq/20k_michiganensis/Assembly/assembly.fasta --addgenes --addmrna --cpus 32 --outdir prokka_results 
conda deactivate
#conda activate roary
#roary -p 32 -o cluster_proteins -e -n -qc -r --mafft (If you what to do a pangemone, you have to provide at least two file *.gff
#conda deactivate

#si se quiere correr snippy, se puede correr snippy.sh

