process CONTROLFREEC_FREEC2BED {
    tag "$meta.id"
    label 'process_low'

    conda 'modules/nf-core/controlfreec/freec2bed/environment.yml'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/control-freec:11.6b--hdbdd923_0' :
        'biocontainers/control-freec:11.6b--hdbdd923_0' }"

    input:
    tuple val(meta), path(ratio)

    output:
    tuple val(meta), path("*.bed"), emit: bed
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    freec2bed.pl -f ${ratio} ${args} > ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        controlfreec: \$(echo \$(freec -version 2>&1) | sed 's/^.*Control-FREEC  //; s/:.*\$//' | sed -e "s/Control-FREEC v//g" )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        controlfreec: \$(echo \$(freec -version 2>&1) | sed 's/^.*Control-FREEC  //; s/:.*\$//' | sed -e "s/Control-FREEC v//g" )
    END_VERSIONS
    """
}
