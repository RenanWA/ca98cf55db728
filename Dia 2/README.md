### QUESTÂO 1 ###


### QUESTÂO 2 ###
Para gerar o arquivo com as regiões não cobertas, foi utilizado o pacote bedtools, e executados os comando a seguir:
```
bedtools genomecov -ibam analysis_ready_reads.bam -bga | awk '$4==0' > coverageZero.bed
bedtools intersect -a coverage.bed -b coverageZero.bed > regioes_nao_cobertas.bed
```
A primeira linha cria um arquivo BED contendo apenas as regiões com cobertura zero. Entretanto, em um kit de exoma, esperamos sequenciar apenas as regiões codificantes, e o arquivo gerado inclui também as não-codificantes.  
Para resolver este problema, executamos a segunda linha, que seleciona apenas as regiões com cobertura zero que intersectam com a região teoricamente sequenciada pelo kit de exoma. Dessa forma geramos o resultado desejado: um arquivo BED que contém apenas as regiões que deveriam conter leituras, mas não apresentam nenhuma.  
  
Para continuar a avaliação da cobertura, foi executada a instrução abaixo:
```
bedtools coverage -hist -a coverage.bed -b analysis_ready_reads.bam | grep ^all > bedstats.txt
```
O arquivo gerado contém um histograma das coberturas presentes no alinhamento, cujo gráfico pode ser visto em "HistogramaCobertura.png".  
Nele, percebemos que o nível de cobertura mais frequente é um pouco superior a 100, e a vasta maioria das bases apresenta cobertura superior a 30, o que é um limite razoável para afirmar se uma variante ocorre em homozigose ou heterozigose. Assim, podemos concluir que o alinhamento apresenta boa qualidade para a grande maioria das posições, contendo poucas regiões (relativamente) do exoma que não são cobertas por nenhuma leitura.

### QUESTÂO 3 ###
Para obter as informações sobre o alinhamento, foi utilizado o pacote samtools, com o seguine código:
```
samtools stats -r grch38.chr22.fasta analysis_ready_reads.bam > samtools_stats.txt
```
A partir daí foram extraídos os parâmetros pedidos e colocados no arquivo TSV:  
```
Dado pedido  | campo no samtools_stats.txt  
nreads       | reads mapped (número de reads alinhadas, incluindo as com qualidade ruim)  
proper_pairs | reads properly paired (reads alinhadas com código 0x2, ou seja, as duas reads do par foram alinhadas à referência, antiparalelas uma à outra, e a uma distância consistente)  
mapQ_0       | reads MQ0 (reads que podem ser alinhadas a mais de uma posição na referência)
```
