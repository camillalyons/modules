process PAIRIX {
    tag "$meta.id"
    label 'process_medium'

    conda 'modules/nf-core/pairix/environment.yml'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pairix:0.3.7--py36h30a8e3e_3' :
        'biocontainers/pairix:0.3.7--py36h30a8e3e_3' }"

    input:
    tuple val(meta), path(pair)

    output:
    tuple val(meta), path(pair), path("*.px2"), emit: index
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    pairix \\
        $args \\
        $pair

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pairix: \$(echo \$(pairix --help 2>&1) | sed 's/^.*Version: //; s/Usage.*\$//')
    END_VERSIONS
    """
}
