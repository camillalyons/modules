process BEDTOOLS_MASKFASTA {
    tag "$meta.id"
    label 'process_single'

    conda 'modules/nf-core/bedtools/maskfasta/environment.yml'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.30.0--hc088bd4_0' :
        'biocontainers/bedtools:2.30.0--hc088bd4_0' }"

    input:
    tuple val(meta), path(bed)
    path  fasta

    output:
    tuple val(meta), path("*.fa"), emit: fasta
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bedtools \\
        maskfasta \\
        $args \\
        -fi $fasta \\
        -bed $bed \\
        -fo ${prefix}.fa
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version | sed -e "s/bedtools v//g")
    END_VERSIONS
    """
}
