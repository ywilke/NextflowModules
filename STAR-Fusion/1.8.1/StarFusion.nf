process StarFusion {
    tag {"StarFusion ${sample_id}"}
    label 'StarFusion_1_8_1'
    container = 'quay.io/biocontainers/star-fusion:1.8.1--2'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
    tuple sample_id, file(fastqs)
    file star_index
    file(reference)
    

    output:
    tuple sample_id, file("*fusion_predictions.tsv"), file("*.{tsv,txt}")


    script:
    def avail_mem = task.memory ? "--limitGenomeGenerateRAM ${task.memory.toBytes() - 100000000}" : ''

    def read_args = params.singleEnd ? "--left_fq ${fastqs[0]}" : "--left_fq ${fastqs[0]} --right_fq ${fastqs[1]}"
    
    """
    STAR \\
        --genomeDir ${star_index} \\
        --readFilesIn ${read_args} \\
        --twopassMode Basic \\
        --outReadsUnmapped None \\
        --chimSegmentMin 12 \\
        --chimJunctionOverhangMin 12 \\
        --alignSJDBoverhangMin 10 \\
        --alignMatesGapMax 100000 \\
        --alignIntronMax 100000 \\
        --chimSegmentReadGapMax 3 \\
        --alignSJstitchMismatchNmax 5 -1 5 5 \\
        --runThreadN ${task.cpus} \\
        --outSAMstrandField intronMotif ${avail_mem} \\
        --outSAMunmapped Within \\
        --outSAMtype BAM Unsorted \\
        --outSAMattrRGline ID:GRPundef \\
        --chimMultimapScoreRange 10 \\
        --chimMultimapNmax 10 \\
        --chimNonchimScoreDropMin 10 \\
        --peOverlapNbasesMin 12 \\
        --peOverlapMMp 0.1 \\
        --readFilesCommand zcat \\
        --sjdbOverhang 100 \\
        --chimOutJunctionFormat 1




    STAR-Fusion \
        --genome_lib_dir ${reference} \
        -J ${chim_junctions} \
        ${read_args} \
        --CPU ${task.cpus} \
        --examine_coding_effect \
        --output_dir .
    """

}
