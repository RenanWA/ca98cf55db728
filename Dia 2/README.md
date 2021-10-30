### QUESTÂO 1 ###


### QUESTÂO 2 ###
O código é:
'''

'''


### QUESTÂO 3 ###
Para obter as informações sobre o alinhamento, foi utilizado o pacote samtools, com o seguine código:
```
samtools stats -r grch38.chr22.fasta analysis_ready_reads.bam > samtools_stats.txt
```
A partir daí foram extraídos os parâmetros pedidos e colocados no arquivo TSV:  
Dado pedido  | campo no samtools_stats.txt  
nreads       | reads mapped (número de reads alinhadas, incluindo as com qualidade ruim)  
proper_pairs | reads properly paired (reads alinhadas com código 0x2, ou seja, as duas reads do par foram alinhadas à referência, antiparalelas uma à outra, e a uma distância consistente)  
mapQ_0       | reads MQ0 (reads que podem ser alinhadas a mais de uma posição na referência)
