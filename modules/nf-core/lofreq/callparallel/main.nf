process LOFREQ_CALLPARALLEL {
    tag "$meta.id"
    label 'process_high'

    conda 'modules/nf-core/lofreq/callparallel/environment.yml'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/lofreq:2.1.5--py38h588ecb2_4' :
        'biocontainers/lofreq:2.1.5--py38h588ecb2_4' }"

    input:
    tuple val(meta), path(bam), path(bai), path(intervals)
    path fasta
    path fai

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def options_intervals = intervals ? "-l ${intervals}" : ""
    """
    lofreq \\
        call-parallel \\
        --pp-threads $task.cpus \\
        $args \\
        $options_intervals \\
        -f $fasta \\
        -o ${prefix}.vcf.gz \\
        $bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        lofreq: \$(echo \$(lofreq version 2>&1) | sed 's/^version: //; s/ *commit.*\$//')
    END_VERSIONS
    """
}
