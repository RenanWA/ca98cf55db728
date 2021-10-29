### CONFIGURAÇÃO DO AMBIENTE ###
Inicialmente, foi configurado o ambiente gatk com conda, utilizando os pacotes padrão fornecidos no arquivo "gatkcondaenv.yml" como especificado no site oficial: https://gatk.broadinstitute.org/hc/en-us/articles/360035889851--How-to-Install-and-use-Conda-for-GATK4.
Em seguida, foi instalado o pacote "samtools", no mesmo ambiente

Além disso, foi baixado o arquivo com os SNPs comuns conhecidos do dbSNP (https://ftp.ncbi.nih.gov/snp/organisms/human_9606/VCF/), com o nome "00-common_all.vcf".

### DISPOSIÇÃO DOS ARQUIVOS ###
Dentro da pasta do gatk, foi criada a pasta "Desafio", na qual foram colocados o arquivo de referência ("grch38.chr22.fasta"), as reads ("amostra-lbb_R1.fq" e "amostra-lbb_R2.fq"), a amostra do gabarito ("pequeno-gabarito.vcf") e o arquivo com os SNPs, todos devidamente descompactados.
Nesta pasta também foi colocado o arquivo "pipeline.sh", descrito abaixo.

### OBTENÇÂO DAS VARIANTES ###
Para obter as variantes, seguiu-se a pipeline de boas praticas do GATK, passando pelas seguintes etapas:
-> Conversão dos dois arquivos com pares de leituras em um unico .bam
-> Mapear reads à referencia
-> Remover duplicatas de sequenciamento
-> Recalibrar os scores de qualidade das leituras
-> Realizar a chamada de variantes com HaplotypeCaller
-> Filtrar as variantes com rede neural convolucional

Em todas as etapas foram usados os parametros padrao.

Para reproduzir esta etapa, basta organizar os arquivos como descrito e executar o script "pipeline.sh".

### RESULTADO ###
Há dois resultados possiveis: O arquivo "variantes .vcf" possui todas as variantes encontradas. O arquivo "variantes_filtradas.vcf" apresenta apenas as variantes que passaram na etapa de filtragem, como descrito na pipeline de boas praticas do GATK.
A principio, o arquivo "variantes_filtradas.vcf" é o mais adequado para continuar as analises, mas como nao sei qual dos dois era esperado pelos(as) organizadores(as) dos desafio como resposta, forneço ambos os arquivos.
