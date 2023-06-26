#map to reference 
bbmap.sh ref=referencia in=input1 in2=input2 minid=0.85 out=out.bam -Xmx12g
#Para ver profundidad y coverage usando el .bam generado mediante map to reference
pileup.sh in=out.bam out=depth.txt 
