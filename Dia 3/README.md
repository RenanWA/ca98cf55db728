### DISPOSIÇÃO DOS ARQUIVOS ###
Tal qual nos Dia 2, todas as instruções executadas aqui assumem que o terminal está aberto na pasta específicada no README do Dia 1, com todos os arquivos produzidos nos dias anteriores.  

### OBTENDO MÉTRICAS DA CHAMADA DE VARIANTES E RAZÃO Ti/Tv ###
Para obter várias métricas a respeito das variantes encontradas, foi utilizada a ferramenta CollectVariantCallingMetrics, do GATK, executando sobre o arquivo "variantes_filtradas.vcf", gerado no dia anterior:
```
../gatk --java-options -Xmx6G CollectVariantCallingMetrics -I variantes_filtradas.vcf --DBSNP 00-common_all_chr22_corrected.vcf -O metricas_das_variantes
```
Como resultado, são gerados dois arquivos, um com resumo e outro com detalhes a respeito da chamada de variantes.  
Em ambos, encontra-se os campos "DBSNP_TITV" e "NOVEL_TITV". Estes valores são a razão Ti/Tv para variantes presentes e ausentes no dbSNP, respectivamente. Os números encontrados foram:
```
DBSNP_TITV = 2,560345
NOVEL_TITV = 2,031963
```
De acordo com o site do Broad Institute (https://gatk.broadinstitute.org/hc/en-us/articles/360035531572-Evaluating-the-quality-of-a-germline-short-variant-callset), para dados de sequenciamento de exoma, o valor esperado é entre 3.0 e 3.3. Como o valor obtido é menor, temos indícios da ocorrência de falsos positivos no VCF analisado.

### NÚMERO DE VARINTES NA REGIÃO DE INTERESSE ###
Para encontrar o número de variantes presentes na região de interesse, entre as posições 16000000 e 20000000, simplesmente foram extraídas de "variantes_filtradas.vcf" as linhas cuja segunda coluna (posição da variante) se encontra entre estes valores:
```
awk '$2>=16000000 && $2<=20000000' variantes_filtradas.vcf > variantes_regiao_iteresse.vcf
```
O arquivo "variantes_regiao_iteresse.vcf" possui 420 linhas, que é o número de variantes identificadas nesta região.

### ESTUDANDO O CONTEÚDO DO VCF ###
* **VARIANTE NÃO-SINÔNIMA**
