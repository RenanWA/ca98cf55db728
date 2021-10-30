### DISPOSIÇÂO DOS ARQUIVOS ###
Todas as instruções executadas aqui assumem que os terminal está aberto na pasta específicada no README do Dia 1, com todos os arquivos fornecidos e criados neste dia, mais o arquivo BED fornecido, já descompactado.

### QUESTÂO 1 ###
O método de filtragem de variantes escolhido foi o recomendado pela pipeline de boas práticas do GATK, que já foi executado no script do Dia 1, mas que reproduzo aqui para facilitar a avaliação:
```
../gatk --java-options -Xmx6G CNNScoreVariants -R grch38.chr22.fasta -V variantes.vcf -O variantes_com_score.vcf
../gatk --java-options -Xmx6G FilterVariantTranches -V variantes_com_score.vcf --resource 00-common_all_chr22_corrected.vcf --resource pequeno-gabarito.vcf --info-key CNN_1D -O variantes_filtradas.vcf
```
A ferramenta usa uma rede neural convolucional (já pré-treinada), que avalia a variante identificada e seu contexto (as bases em torno da variante), e atribui uma pontuação a ela. A ferramenta seguinte seleciona as variantes com base nesta pontuação. A escolha do limiar de filtragem envolve um balanço entre sensibilidade e especificidade, e os valores padrão foram escolhidos de modo a maximizar o equilíbrio entre eles (medido pelo score F1) para dados do genoma humano. Na falta de motivos para alterar estes valores, optei por utilizar a configuração padrão, obtendo o arquivo "variantes_filtradas.vcf".  
Feita a filtragem, nota-se que apenas sete variantes foram removidas. Isto pode ser atribuído à boa qualidade do alinhamento, conforme avaliado nas próximas questões, de modo que temos bastante certeza de que quase todas as variantes identificadas são reais, e não artefatos.

### QUESTÂO 2 ###
Para gerar o arquivo com as regiões não cobertas, foi utilizado o pacote bedtools, e executados os comandos a seguir:
```
bedtools genomecov -ibam analysis_ready_reads.bam -bga | awk '$4==0' > coverageZero.bed
bedtools intersect -a coverage.bed -b coverageZero.bed > regioes_nao_cobertas.bed
```
A primeira linha cria um arquivo BED contendo apenas as regiões com cobertura zero.  
Entretanto, em um kit de exoma, esperamos sequenciar apenas as regiões codificantes, e o arquivo gerado inclui também as não-codificantes.  
Para resolver este problema, executamos a segunda linha, que seleciona apenas as regiões com cobertura zero que intersectam com a região teoricamente sequenciada pelo kit de exoma.  
Dessa forma, foi obtido o resultado desejado: um arquivo BED que contém apenas as regiões que deveriam conter leituras, mas não apresentam nenhuma.  
  
Para continuar a avaliação da cobertura, foi executada a instrução abaixo:
```
bedtools coverage -hist -a coverage.bed -b analysis_ready_reads.bam | grep ^all > bedstats.txt
```
O arquivo gerado contém um histograma das coberturas presentes no alinhamento, cujo gráfico pode ser visto em "HistogramaCobertura.png".  
Nele, percebemos que o nível de cobertura mais frequente é um pouco superior a 100, e a vasta maioria das bases apresenta cobertura superior a 30, o que é um limite razoável para afirmar se uma variante ocorre em homozigose ou heterozigose. Assim, pode-se concluir que o alinhamento apresenta boa qualidade para a grande maioria das posições, contendo poucas regiões (relativamente) do exoma que não são cobertas por nenhuma leitura.

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
Dos dados obtidos, constata-se que a vasta maioria das reads (99.8%) foi alinhada corretamente (proper_pairs), e 4.8% apresentam ambiguidade (score 0).  
Como estamos lidando com leituras Illumina (short reads), a ocorrência de ambiguidades é esperada, e o número 4.8% não surpreende. Porém, dado que quase todas as leituras alinharam com código 0x2, é possível dizer que o alinhamento apresenta boa qualidade, e os dados estão adequados para prosseguir com a análise.
