process ViewSort {
    tag {"Sambamba ViewSort ${sample_id} - ${rg_id}"}
    label 'Sambamba_0_7_0'
    label 'Sambamba_0_7_0_ViewSort'
    container = 'quay.io/biocontainers/sambamba:0.7.0--h89e63da_1'
    shell = ['/bin/bash', '-euo', 'pipefail']

    input:
    tuple sample_id, rg_id, file(sam_file)

    output:
    tuple sample_id, rg_id, file("${sam_file.baseName}.sort.bam"), file("${sam_file.baseName}.sort.bam.bai")

    script:
    """
    sambamba view -t ${task.cpus} -S -f bam $sam_file | sambamba sort -t ${task.cpus} -m ${task.memory.toGiga()}G -o ${sam_file.baseName}.sort.bam /dev/stdin
    """
}
