
process UPD {
    tag "$meta.id"
    label 'process_single'

    conda 'modules/nf-core/upd/environment.yml'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/upd:0.1.1--pyhdfd78af_0':
        'biocontainers/upd:0.1.1--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(vcf)

    output:
        tuple val(meta), path("*.bed"), emit: bed
        path "versions.yml"           , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    upd \\
        --vcf $vcf \\
        $args \\
        | sort -k 1,1 -k 2,2n >${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        upd: \$( upd --version 2>&1 | sed 's/upd, version //' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        upd: \$( upd --version 2>&1 | sed 's/upd, version //' )
    END_VERSIONS
    """

}
