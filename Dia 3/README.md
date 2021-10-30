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

### NÚMERO DE VARIANTES NA REGIÃO DE INTERESSE ###
Para encontrar o número de variantes presentes na região de interesse, entre as posições 16000000 e 20000000, simplesmente foram extraídas de "variantes_filtradas.vcf" as linhas cuja segunda coluna (posição da variante) se encontra entre estes valores:
```
awk '$2>=16000000 && $2<=20000000' variantes_filtradas.vcf > variantes_regiao_iteresse.vcf
```
O arquivo "variantes_regiao_iteresse.vcf" possui 420 linhas, que é o número de variantes identificadas nesta região.

### ESTUDANDO O CONTEÚDO DO VCF ###
* **GERANDO ANOTAÇÕES**
O arquivo "variantes_filtradas.vcf" foi anotado com a ferramenta Funcotator do GATK. Para isto, foi criado o diretório "data_sources", e nele foram colocados:
* O arquivo "gnomAD_exome.tar.gz", obtido de https://console.cloud.google.com/storage/browser/broad-public-datasets/funcotator/funcotator_dataSources.v1.7.20200521s?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))&prefix=&forceOnObjectsSortingFiltering=false
* A pasta "gencode" e todo o seu conteúdo, obtido do mesmo link
O arquivo foi descompactado com
```
tar -zxf gnomAD_exome.tar.gz
```
Em seguida, foi executado o Funcotator:
```
../gatk --java-options -Xmx6G Funcotator -V variantes_filtradas.vcf -R grch38.chr22.fasta -O variantes_anotadas --output-file-format VCF --data-sources-path data_sources/ --ref-version hg38
```

* **VARIANTE NÃO-SINÔNIMA**
O arquivo gerado (variantes_anotadas.vcf) inclui diversas anotações relativas às variantes. Como exemplo de variante não-sinônima, foi escolhida uma linha (aleatória) que apresenta a tag "MISSENSE". Abaixo, reproduzo a linha 235 do vcf:
```
chr22	15528179	.	G	T	537.64	PASS	AC=1;AF=0.500;AN=2;BaseQRankSum=-3.312;CNN_1D=-5.608;DP=129;ExcessHet=3.0103;FS=8.115;FUNCOTATION=[OR11H1|hg38|chr22|15528179|15528179|MISSENSE||SNP|G|G|T|g.chr22:15528179G>T|ENST00000252835.5|+|1|21|c.21G>T|c.(19-21)caG>caT|p.Q7H|0.38154613466334164|TGACCTTGCAGGTCACTGGCC|OR11H1_ENST00000643195.1_FIVE_PRIME_FLANK|5.90082e-02|5.29412e-03|6.48907e-03|3.68324e-03|1.52469e-02|1.44573e-02|1.61890e-02|6.12431e-02|6.45161e-02|5.69620e-02|3.05259e-02|3.39436e-02|3.82353e-01|2.04360e-03|2.73438e-02|3.81098e-02|6.23285e-02|2.85090e-01|2.95824e-01|2.74269e-01|5.56188e-02|7.30613e-02|8.60215e-02|1.52174e-01|7.89848e-02|6.70290e-02|5.58184e-02|1.15840e-01|3.04054e-01|3.40000e-01|3.14685e-02|3.37079e-02|2.92479e-02|7.30613e-02|9.96672e-02|1.99660e-02|2.28540e-02|1.81881e-02|rs2259944|RF];MLEAC=1;MLEAF=0.500;MQ=60.00;MQRankSum=0.000;QD=4.60;ReadPosRankSum=-0.392;SOR=1.847	GT:AD:DP:GQ:PL	0/1:93,24:117:99:545,0,3145
```

* **VARIANTE NO gnomAD COM MAF < 0.01**
Para anotar as frequências de cada alelo, o arquivo "variantes_filtradas.vcf" também foi submetido ao site do VEP (https://www.ensembl.org/Multi/Tools/VEP?db=core). Foram utilizadas as configurações padrão, exceto pelo campo "Frequency data for co-located variants", no menu "Variants and frequency data": nele foi selecionado o item "gnomAD (exomes) allele frequencies".  
Após o término do processo de anotação, as variantes foram filtradas por: "gnomAD AF < 0.01".  
O primeiro resultado, com gnomAD AF 0.009317, foi a variante que ocorre na posição 15695500. A linha correspondente do arquivo "variantes_anotadas.vcf" é reproduzido a seguir:
```
chr22	15695500	.	A	C	70.64	PASS	AC=1;AF=0.500;AN=2;BaseQRankSum=1.453;CNN_1D=0.018;DP=59;ExcessHet=3.0103;FS=12.203;FUNCOTATION=[POTEH|hg38|chr22|15695500|15695500|INTRON||SNP|A|A|C|g.chr22:15695500A>C|ENST00000343518.11|+|||c.e2+15A>C|||0.38902743142144636|GCAGTAGCCAACTATGTCAGC|POTEH_ENST00000621704.4_INTRON|9.31677e-03|0.00000e+00|0.00000e+00|0.00000e+00|6.04839e-03|7.93651e-03|4.09836e-03|0.00000e+00|0.00000e+00||0.00000e+00|0.00000e+00||0.00000e+00|0.00000e+00|0.00000e+00|7.31707e-03||||1.07914e-02|0.00000e+00|||0.00000e+00|0.00000e+00|0.00000e+00|0.00000e+00|||0.00000e+00|0.00000e+00|0.00000e+00|2.01342e-02|3.51540e-03|2.01342e-02|1.35135e-02|2.23214e-02|rs1299193470|];MLEAC=1;MLEAF=0.500;MQ=60.00;MQRankSum=0.000;QD=1.24;ReadPosRankSum=-0.222;SOR=0.031	GT:AD:DP:GQ:PL	0/1:51,6:57:78:78,0,2071
```
