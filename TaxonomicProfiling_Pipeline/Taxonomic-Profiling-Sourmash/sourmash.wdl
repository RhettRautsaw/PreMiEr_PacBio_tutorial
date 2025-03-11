version 1.0

workflow SourmashProfiling {
  # Description
  meta {
    description: "Sourmash Profiling PacBio HiFi Data"
  }
  
  # Input
  input {
    Array[Int] ksizes
    Int? threshold_bp
    Int? threads
    
  }

  # Tasks
  scatter (sample in samples) {
    call merge2fastq {
      input:
        sample_name = sample.sample_id
        bams = sample.hifi_reads
    }
    
    scatter (ks in ksize) {
      call SourmashSketchDNA {
        input:
          sample_name = sample.sample_id,
          fastq = merge2fastq.mergedReads
          ksize = ks
      }
      
      call SourmashGather {
        input:
          sample_name = sample.id,
          ksize = ks,
          sketch_file = SourmashSketchDNA.signature,
          search_database = databases[ksize.indexOf(ks)]
      }
      
      call SourmashTaxAnnotate {
        input:
          sample_name = sample.id,
          ksize = ks,
          gather_file = SourmashGather.gather_results,
          lineage_file = lineage_file
      }
    }
  }
  
  # Output
  output {
    Array[File] merged_bam
    Array[File] merged_bam_index
    Array[File] merged_fastq
  }
}

task merge2fastq {
  input {
    String sample_name
    Array[File] bams
  }
  
  Int threads = 8
  Int mem_gb = 16
  Int disk_size = ceil(size(bams, "GB") * 4 + 20)
  
  command <<<
    mkdir -p 0-merged
    pbmerge -o ~{sample_name}.merged ~{sep=' ' bams}
    bam2fastq -o ~{sample_name}.merged ~{sample_name}.merged.bam
    pigz -9 -p ~{threads} ~{sample_name}.merged.fastq
  >>>
  
  output {
    File merged_bam = "0-merged/~{sample_name}.merged.bam"
    File merged_bam_index = "0-merged/~{sample_name}.merged.bam.pbi"
    File merged_fastq = "0-merged/~{sample_name}.merged.fastq.gz"
  }
  
  runtime {
    docker: "quay.io/pacbio/pb_wdl_base@sha256:4b889a1f21a6a7fecf18820613cf610103966a93218de772caba126ab70a8e87"
    cpu: threads
    memory: mem_gb + " GB"
    disk: disk_size + " GB"
    disks: "local-disk " + disk_size + " HDD"
    preemptible: runtime_attributes.preemptible_tries
    maxRetries: runtime_attributes.max_retries
    awsBatchRetryAttempts: runtime_attributes.max_retries  # !UnknownRuntimeKey
    zones: runtime_attributes.zones
  }
}

task SourmashSketchDNA {
  input {
    String sample_name
    Int ksize
  }

  command <<EOF
    mkdir -p output.sourmash-profiling/1-sketch
    sourmash sketch dna inputs/~{sample_name}.fasta -p k=~{ksize},dna,scaled=1000,abund \
                                    --name ~{sample_name} -o output.sourmash-profiling/1-sketch/~{sample_name}.dna.sig.zip
  EOF

  output {
    File signature = "output.sourmash-profiling/1-sketch/~{sample_name}.dna.sig.zip"
  }

  runtime {
    docker: "quay.io/biocontainers/sourmash:4.8.11--hdfd78af_0"
  }
}

task SourmashGather {
  input {
    String sample_name
    Int ksize
    File sketch_file
    File search_database
  }

  command <<EOF
    mkdir -p output.sourmash-profiling/2-gather
    sourmash gather ~{sketch_file} ~{search_database} > output.sourmash-profiling/2-gather/~{sample_name}.k~{ksize}.gather.csv
  EOF

  output {
    File gather_results = "output.sourmash-profiling/2-gather/~{sample_name}.k~{ksize}.gather.csv"
  }

  runtime {
    docker: "quay.io/biocontainers/sourmash:4.8.11--hdfd78af_0"
  }
}

task SourmashTaxAnnotate {
  input {
    String sample_name
    Int ksize
    File gather_file
    File lineage_file
  }

  command <<EOF
    mkdir -p output.sourmash-profiling/3-taxprofile
    sourmash tax annotate -g ~{gather_file} -t ~{lineage_file} -o output.sourmash-profiling/3-taxprofile/~{sample_name}.k~{ksize}.gather.with-lineages.csv
  EOF

  output {
    File annotated_results = "output.sourmash-profiling/3-taxprofile/~{sample_name}.k~{ksize}.gather.with-lineages.csv"
  }

  runtime {
    docker: "quay.io/biocontainers/sourmash:4.8.11--hdfd78af_0"
  }
}
