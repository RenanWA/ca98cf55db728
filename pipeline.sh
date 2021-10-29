#!/bin/sh
# Script para executar a pipeline do primeiro dia do Desafio

# Transformar os pares de reads em um unico arquivo .bam
../gatk FastqToSam -F1 amostra-lbb_R1.fq -F2 amostra-lbb_R2.fq -O unaligned_read_pairs.bam -SM AMOSTRA-LBB

# Criar arquivos auxiliares para a referencia
../gatk CreateSequenceDictionary -R grch38.chr22.fasta
../gatk BwaMemIndexImageCreator -I grch38.chr22.fasta
samtools faidx grch38.chr22.fasta

# Da lista de SNPs conhecidos, extrair o cromossomo 22 e corrigir seu nome de 22 para chr22
grep -w '^#\|^#CHROM\|^22' 00-common_all.vcf > 00-common_all_chr22.vcf
awk '{if($0 !~ /^#/) print "chr"$0; else print $0}' 00-common_all_chr22.vcf > 00-common_all_chr22_corrected.vcf

# Criar arquivos auxiliares para as listas de SNPs conhecidos
../gatk --java-options -Xmx6G IndexFeatureFile -I 00-common_all_chr22_corrected.vcf
../gatk --java-options -Xmx6G IndexFeatureFile -I pequeno-gabarito.vcf


# Inicio da pipeline do GATK
# Alinhar as reads com a referencia
../gatk --java-options -Xmx6G BwaSpark -I unaligned_read_pairs.bam -R grch38.chr22.fasta -O aligned_reads.bam

# Marcar reads duplicadas
../gatk --java-options -Xmx6G MarkDuplicatesSpark -I aligned_reads.bam -O marked_duplicates.bam -M marked_dup_metrics.txt

# Associar as reads ao read group AMOSTRA-LBB
../gatk --java-options -Xmx6G AddOrReplaceReadGroups -I marked_duplicates.bam -O marked_duplicates2.bam -LB AMOSTRA-LBB -PL ILLUMINA -PU AMOSTRA-LBB -SM AMOSTRA-LBB

# Corrigir o score de qualidade das reads, baseado nos locais com SNPs comuns conhecidos
../gatk --java-options -Xmx6G BaseRecalibrator -I marked_duplicates2.bam -R grch38.chr22.fasta --known-sites 00-common_all_chr22_corrected.vcf --known-sites pequeno-gabarito.vcf -O recal_data.table
../gatk --java-options -Xmx6G ApplyBQSR -I marked_duplicates2.bam -R grch38.chr22.fasta --bqsr-recal-file recal_data.table -O analysis_ready_reads.bam

# Realizar a chamada de variantes
../gatk --java-options -Xmx6G HaplotypeCaller -I analysis_ready_reads.bam -R grch38.chr22.fasta -comp pequeno-gabarito.vcf -O variantes.vcf

# Filtrar as variantes
../gatk --java-options -Xmx6G CNNScoreVariants -R grch38.chr22.fasta -V variantes.vcf -O variantes_com_score.vcf
../gatk --java-options -Xmx6G FilterVariantTranches -V variantes_com_score.vcf --resource 00-common_all_chr22_corrected.vcf --resource pequeno-gabarito.vcf --info-key CNN_1D -O variantes_filtradas.vcf


