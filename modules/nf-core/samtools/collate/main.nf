process SAMTOOLS_COLLATE {
    tag "$meta.id"
    label 'process_medium'

    conda 'modules/nf-core/samtools/collate/environment.yml'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0':
        'biocontainers/samtools:1.17--h00cdaf9_0' }"

    input:
    tuple val(meta), path(input)
    path fasta

    output:
    tuple val(meta), path("*.bam"),  emit: bam, optional: true
    tuple val(meta), path("*.cram"), emit: cram, optional: true
    tuple val(meta), path("*.sam"),  emit: sam,  optional: true
    path "versions.yml",             emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reference = fasta ? "--reference ${fasta}" : ""
    def extension = args.contains("--output-fmt sam") ? "sam" :
                    args.contains("--output-fmt bam") ? "bam" :
                    args.contains("--output-fmt cram") ? "cram" :
                    "bam"
    if ("$input" == "${prefix}.${extension}") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    """
    samtools \\
        collate \\
        $args \\
        ${reference} \\
        -@ $task.cpus \\
        -o ${prefix}.${extension} \\
        $input

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
