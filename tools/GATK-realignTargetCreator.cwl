#!/usr/bin/env cwl-runner
#
# To use it as stand alone tool - example: "cwltool --tmpdir-prefix="$(pwd)"/name_of_tmpDir/ --tmp-outdir-prefix="$(pwd)"/name_of_tmpDir/ ./realignTargetCreator.cwl ./realignTargetCreator.json"

# Authors: farahk@student.unimelb.edu.au and skanwal@student.unimelb.edu.au UNIVERSITY OF MELBOURNE
# Developed for CWL consortium http://commonwl.org/

class: CommandLineTool

description: |
  This is a tool wrapper for GATK tool called realignerTargetCreator. It accepts 3 input files and produces a file containing list of target intervals to pass to the IndelRealigner.
  Usage: java -jar GenomeAnalysisTK.jar -T RealignerTargetCreator -R reference.fasta -I input.bam --known indels.vcf -o forIndelRealigner.intervals 
  Options: 
    -T tool Tool name to be executed
    -R File Reference sequence in fasta format
    -I File  bam file produced from sam to bam conversion step
    --known File set of known indels   
    
requirements:
  - import: node-engine.cwl
  - import: envvar-global.cwl
  - import: gatk-docker.cwl
  - class: CreateFileRequirement
    fileDef:
      - filename:
          engine: node-engine.cwl
          script: $job['inputBam_realign'].path.split('/').slice(-1)[0]
        fileContent:
          engine: "cwl:JsonPointer"
          script: /job/inputBam_realign
          
arguments:
  - valueFrom: "/tmp/job_tmp"
    position: 2
    separate: false
    prefix: "-Djava.io.tmpdir="
    
  - valueFrom: "/home/biodocker/bin/gatk/target/GenomeAnalysisTK.jar"
    position: 3
    prefix: "-jar"

inputs:

  - id: "#java_arg"
    type: string
    default: "-Xmx4g"
    inputBinding: 
      position: 1
     
  - id: "#RealignerTarget"
    type: string
    default: "RealignerTargetCreator"
    inputBinding: { position: 4, prefix: "-T" }
    description: tool used for this step from GATK jar

     
  - id: "#reference"
    type: File
    inputBinding:
      position: 5
      prefix: "-R"
      secondaryFiles:
        - ".amb"
        - ".ann"
        - ".bwt"
        - ".pac"
        - ".rbwt"
        - ".rpac"
        - ".rsa"
        - ".sa"
        - ".fai"
        - "^.dict"

  - id: "#inputBam_realign"
    type: File
    description: bam file produced after mark-duplicates execution
    inputBinding:
      position: 6
      prefix: "-I"
      secondaryFiles:
        - "^.bai"

  - id: "#known"  
    type:
      type: array
      items: File
      inputBinding: { prefix: "--known" }
    inputBinding: 
      position: 7

  - id: "#outputfile_realignTarget"
    type: string
    description: name of the output file from realignTargetCreator
    inputBinding:
      position: 8
      prefix: "-o"

outputs:
  - id: "#output_realignTarget"
    type: File
    outputBinding: 
      glob:
        engine: cwl:JsonPointer
        script: /job/outputfile_realignTarget

baseCommand: ["java"]
