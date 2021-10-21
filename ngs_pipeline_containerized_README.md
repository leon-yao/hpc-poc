# ngs_pipeline (containerized)

## Introduction

The NGS pipeline is a robust and efficient software to analyze NGS experiments in a reproducible manner. 
It provides two standard analysis pipelines (RNA-Seq and Exome-Seq) and supports: read subsampling, read filtering 
based on quality, detection of ribosomal RNAs, detection of adapter contamination, read alignment vs reference genomes, 
counting reads in genomic features, single-nucleotide variant calling, coverage computation, detection of junction ends, 
and quality reports. The pipeline is flexible and can also perform non-standard analyses (non-human/mouse, indel calling).

## Quick Start

The quick start requires at least 64GiB memory and 8GiB of tmp disk space.  The resources files consume ~120GiB of disk space.
16 CPU's are recommended for the RNA-Seq pipeline.

### Create resources directory and install resource files

    mkdir /path/to/resources
    cd /path/to/resources
    cp /path/from/ngs_pipeline_resources_4.2.2.tar.gz .
    tar xvfz ngs_pipeline_resources_4.2.2.tar.gz
    export RESOURCES=$PWD/ngs_pipeline_resources_4.2.2
    
### Create and cd into a working directory

    mkdir /path/to/working_dir
    cd /path/to/working_dir
    
### Install docker container tarball
    
    #copy the tarball to the new directory
    cp /path/from/ngs_pipeline_docker_4.2.2.tar.gz .
    
    #install docker image
    sudo docker load < ngs_pipeline_docker_4.2.2.tar.gz
    
### Download test data

    cp /path/from/test_data.tar.gz .
    tar xvfz test_data.tar.gz

#### Test data config file

This is an example config.txt file that is included in the test data.

    ## template
    template_config: RNASeq-mouse-stranded-config.txt

    ## input
    input_file: /working_dir/test_data/test_data_R1.fastq.gz
    input_file2:
    paired_ends: FALSE
    quality_encoding: illumina1.8

    ## output
    save_dir: /working_dir/test_data/output
    overwrite_save_dir: never
    prepend_str: test_data

    ## aligner
    alignReads.sam_id: test_data
    
### Validate the config file

Running the validation command utilizes 2 bind points.  The first is the path to the working directory that was just created.  The second bind
point is the path to the resource directory.  The --validate command is an ngs_pipeline internal command which will run checks to see that 
all dependencies required to run the workflow described in the config file exists and is valid.

    $ sudo docker run \
    -v $PWD:/working_dir \
    -v $RESOURCES:/resources \
    gne/ngs_pipeline:4.2.2 \
    --validate /working_dir/test_data/config.txt
    
### Run the workflow

    sudo docker run \
    -v $PWD:/working_dir \
    -v $RESOURCES:/resources \
    gne/ngs_pipeline:4.2.2 \
    -t 16 \
    --run /working_dir/test_data/config.txt

## Containerization

This application was originally developed for Genentech's legacy HPC cluster.  In order to keep this software operational, it 
is necessary to build the ngs_pipeline application and it's environment into the software container.  This will allow the software
to be portable across platforms including cloud based platforms.  Both singularity and docker platforms are used for this purpose.

## Dependencies

### Resource Files

In order to process the input data through the workflows in ngs_pipeline, access to these resource files must be set up and 
configured.  This can be accomplished by "binding" volumes in the appropriate locations.  There are 3 sets of resouce files
that need to be set up:

* GATK Genome References (default location: /resources/gatk_genomes)
* Genomic Features Data (default location: /resources/genomic_features)
* GMAP Genomes (default location: /resources/gsnap_genomes)

### Config Files

The ngs_pipeline application relies on configuration files to guide it's processing of sequence data.  Each sample that is being
processed will need to have a config file that describes how the sample is to be processed.  Configuration information is derived
from a default set of config files that is already set in the container.  In order to overide this default set, you will have to 
mount/bind a directory of default config files.  The location in the container where default configuration files reside:

    /usr/local/lib/R/site-library/HTSeqGenie.gne/config
    
#### Configuration parameters
Configuration files ultimately derive from the default-config.txt configuration file, which enumerates all available parameters and the local-default-config.txt configuration, which has all the Genentech specific default configuration values.
Here is a full list of all available configuration parameters:

##### Template
template_config: An optional file name containing a template configuration file. To locate it, the software first looks in the directory defined by the environment variable HTSEQGENIE_CONFIG and, if not found, in the installed package HTSeqGenie. No default value.

##### Input
* input_file: The path of a FASTQ or gzipped FASTQ file containing the input reads. No default value.
* input_file2: An optional path of a FASTQ or gzipped FASTQ file containing the input paired reads in paired-end sequencing. If present, the parameter paired_ends must be set to TRUE. No default value.
* paired_ends: A logical indicating whether the reads are coming from paired-end sequencing. Default is TRUE.
* quality_encoding: An optional string indicating which quality encoding is used. Possible values are "sanger", "solexa", "illumina1.3", "illumina1.5", "illumina1.8", and "GATK-rescaled". If absent, a non-robust strategy is tried to guess it. No default value.
* subsample_nbreads: An optional integer. If present, the preprocess module randomly subsamples the indicated number of reads from the input files before analysis. This feature is disabled by default.
* chunk_size: An integer indicating how many reads are present in a chunk. This parameter should not be changed. Default is 1e6.
* max_nbchunks: An optional integer. If present, it sets the maximum number of chunks to be processed. This parameter is mostly present for debug purposes. This feature is disabled by default.

##### Output
* save_dir: A directory path indicating where the output results should be stored. No default value.
* overwrite_save_dir: A string indicating how to overwrite/save data in the save_dir directory. Possible values are "never", "erase" and "overwrite". If "never", the pipeline will stop if the indicated save_dir is present. If "erase", the save_dir directory is removed before starting the analysis. Default is "never".
* prepend_str: A string that will be preprended to output filenames. No default value.
* remove_processedfastq: A logical indicating whether the preprocessed FASTQ files before alignment should be removed. Default is TRUE.
* remove_chunkdir: A logical indicating whether the chunks/ subdirectory should be removed. Default is TRUE.
* tmp_dir: A temporary directory where intermediate files will be written to. If set, this should point to a non-replicated directory such as /gne/research/scratch/pipelines/ngs/. If not set, temporary files will be written into the save_dir.

##### System
* num_cores: An integer indicating how many cores should be used on this machine. This value can be overriden by the ngs_pipeline calling script. Default value is 1.

##### Path
* path.genomic_features: A path to the directory that contains the genomic features RData files used for counting. No default.
* path.gsnap_genomes: A path to the directory that contains Gsnap's genomic indices. No default.
* path.gatk: Path to the GATK jar file
* path.gatk_genomes: Path to the folder containing the GATK genome fasta files
* path.picard_tools: Absolute Path to the folder containing the picard tools jar file.

##### Debug
* debug.level: A string indicating which maximal level of debug should be used in the log file. Possible values are "ERROR", "WARN", "INFO" and "DEBUG". Default is "DEBUG".
* debug.tracemem: A logical indicating whether periodic memory information should be included in the log file. Default is TRUE.

##### Trim reads
* trimReads.do: A logical indicating whether the reads should be end-trimmed. Default is FALSE.
* trimReads.length: An integer indicating to what size (in nucleotides) the reads should be trimmed to. No default value.
* trimReads.trim5: An integer indicating how many nucleotides should be trimmed of the 5' end of the read. Default 0.

##### Filter quality
* filterQuality.do: A logical indicating whether the reads should be filtered out based on read nucleotide qualities. A read is kept if the fraction "filterQuality.minFrac" of nucleotides have a quality higher than "filterQuality.minQuality". Default is TRUE.
* filterQuality.minQuality: An integer. See filterQuality.do. Default is 23.
* filterQuality.minFrac: A numeric ranging from 0.0 to 1.0. See filterQuality.do. Default is 0.7.
* filterQuality.minLength: filter reads that are shorter than this length after clipping of low quality tails

##### Detect adapter contamination
* detectAdapterContam.do: A logical indicating whether reads that look contaminated by adapter sequences should be reported (but NOT filtered). Default is TRUE.
* detectAdapterContam.force_paired_end_adapter: A logical indicating whether paired end adapter chemistry was used for single-end sequencing. Default is FALSE.

##### Detect ribosomal RNA
* detectRRNA.do: A logical indicating whether ribosomal RNAs should be filtered out. Default is TRUE.
* detectRRNA.rrna_genome: A string indicating which gsnap genome index to use (-d flag) to detect ribosomal RNAs. No default value.

##### ShortRead report
* shortReadReport.do: A logical indicating whether a ShortRead report should be generated from the preprocessed reads. Default is TRUE.
* shortReadReport.subsample_nbreads: An optional integer indicating how many reads should be subsampled from the preprocessed reads for generating the report. No value indicates to take all of them (can be memory and time consuming). Default is 20e6.

##### Aligner
* alignReads.genome: A string indicating which gsnap genome index to use (-d flag). No default value.
* alignReads.max_mismatches: An optional integer indicating how many maximal mismatches gsnap should use (-m flag). If absent, gsnap uses an automatic value. No default value.
* alignReads.sam_id: A string (--read-group-id flag). No default value.
* alignReads.snp_index: An optional string containing gsnap SNP database index (-v flag). If set "--use-sarray=0" will be addded to gsnap static params. No default value.
* alignReads.splice_index: An optional string containing gsnap splice index (-s flag). No default value.
* alignReads.static_parameters: An optional string containing extra gsnap parameters. No default value.
* alignReads.nbthreads_perchunk: An optional integer indicating how many threads should be used to process one chunk (-t flag). If unspecified, the value is set to min(num_cores, 4). This parameter is mostly given for debug purposes. No default value.
* alignReads.analyzedBam: Specify the set of bam files used to build the analyzed.bam. Choice of *uniq or concordant_uniq. Default is all *uniq.
* alignReads.use_gmapR_gsnap: A logical specifying wether to use the gmap that comes with gmapR or use the one in your PATH

##### Indel-Realignment using GATK
* realignIndels.do: A logical specifying wether to run GATK's IndelRealigner on the analyzed.bam file. Default: FALSE

##### Mark duplicates
markDuplicates.do: A logical specifying wether to mark duplicates in the analyzed.bam file. Default: FALSE

##### Count genomic features
* countGenomicFeatures.do: A logical indicating whether counts per genomic feature should be computed. Default is TRUE.
* countGenomicFeatures.gfeatures: A filename containing the RData file used by the counting features module. The full path is "path.genomic_features"/ "countGenomicFeatures.gfeatures". No default value.
* countGenomicFeatures.preserve_strandedness: FALSE ## Needs to be set to TRUE for stranded RNASeq
* countGenomicFeatures.inter_feature: TRUE ## when true, reads mapping to multiple features will be dropped
* countGenomicFeatures.counting_mode: IntersectionStrict

##### Variants
* analyzeVariants.method: Which method to use for variant calling. Possible choices: VariantTools, GATK
* analyzeVariants.do: A logical indicating whether variant calling should be performed. Default is TRUE.
* analyzeVariants.rep_mask: Path to repeat mask track in bed format

##### specific to VariantTools
* analyzeVariants.with_qual: A logical indicating whether variant calling should take mapping quality into account. Default is TRUE.
* analyzeVariants.bqual: Default is 23.
* analyzeVariants.indels: A logical whether to call indels. Default is TRUE.
* analyzeVariants.dbsnp: Path to dbsnp whitelist as a Vranges RData file
* analyzeVariants.callingFilters: comma separated list of VT calling Filters. Default is nonRef,nonNRef,readCount,likelihoodRatio
* analyzeVariants.postFilters: comma separated list of VT post Filters. No default. For WGS we suggest to activate avgNborCount filter
* analyzeVariants.positions: Path to a GRanges object as RDS used for limiting variant calling on this region
* analyzeVariants.genotype: A logical wether to call genotypes on top of variants. Adds a *.genotyped.vcf.gz file to the output.
* analyzeVariants.vep_options:  Command line arg string that is being passed down to variant_effect_predictor. Default: --vcf --sift b --polyphen b --protein --check_existing --check_alleles --symbol --canonical --ccds --maf_1kg --maf_esp --cache --force_overwrite --no_stats --no_progress --plugin GNECondel,/gne/research/data/bioinfo/igis/prd/VEP/Plugins/config/Condel/config

##### specific to GATK

* gatk.params: Statics GATK parameters. Default: --genotype_likelihoods_model BOTH
* gatk.filter_repeats: A logical indicating wether variants overlapping with a low complexity region should be filtered. 

##### Coverage
* coverage.do: enable/disable coverage computation. Default is TRUE
* coverage.extendReads: A logical whether reads should be extended in the coverage vector. Default is FALSE
* coverage.fragmentLength: Amount by which single ended reads should be extended. Usually defined by the fragment length. No default value.
* coverage.maxFragmentLength: remove long read pairs before computing the coverage. In particular useful when analysing ChIP-Seq. Default is NULL.

## Application Usage

### Running with an interactive shell to the running container
The NGS pipeline requires a configuration file to run. Thorough checks are performed before executing a configuration file. To check 
if a configuration file is valid, type:

    ngs_pipeline --validate config.txt

To run a configuration file:

    ngs_pipeline -t 16 --run config.txt

cd