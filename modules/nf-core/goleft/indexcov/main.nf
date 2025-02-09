process GOLEFT_INDEXCOV {
    tag '${meta.id}'
    label 'process_single'

    conda 'modules/nf-core/goleft/indexcov/environment.yml'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/goleft:0.2.4--h9ee0642_1':
        'biocontainers/goleft:0.2.4--h9ee0642_1' }"

    input:
    tuple val(meta), path(bams), path(indexes)
    tuple val(meta2), path(fai)

    output:
    tuple val(meta), path("${prefix}/*")  , emit: output
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    // indexcov uses BAM files or CRAI
    def input_files = bams.findAll{it.name.endsWith(".bam")} + indexes.findAll{it.name.endsWith(".crai")}
    def extranormalize = input_files.any{it.name.endsWith(".crai")} ? " --extranormalize " : ""
    """
    goleft indexcov \\
        --fai "${fai}"  \\
        --directory "${prefix}" \\
        ${extranormalize} \\
        $args \\
        ${input_files.join(" ")}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        goleft: \$(goleft --version 2>&1 | head -n 1 | sed 's/^.*goleft Version: //')
    END_VERSIONS
    """
    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir "${prefix}"
    touch "${prefix}/${prefix}-indexcov.bed.gz"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        goleft: \$(goleft --version 2>&1 | head -n 1 | sed 's/^.*goleft Version: //')
    END_VERSIONS
    """
}
