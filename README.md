<img src="imgs/PacBio.PNG" width="50%" />

# PreMiEr Bioinformatic Tutorials 

**Rhett Rautsaw** \
PacBio, Senior Scientist, Field Applications Bioinformatic Support (FABS)

# ⚠️ **NOTE** ⚠️
👷 This page is still under contruction. Please check back for updates. 🛠️

# Summary
This page is designed to guide PreMiEr researchers on how to setup, use, and understand PacBio's various WDL workflows (aka pipelines). Specifically, this page hosts several tutorials for running PacBio WDL workflows on [NCShare](https://userguide.ncshare.org/guides/accountreg/). 

If you do not have command line experience or want a more push-button solutions, we recommend checking out PacBio's compatible analysis partners at [BugSeq](https://bugseq.com/pacbio), [DNAstack](https://omics.ai/workflows/pacbio/), [DNAnexus](https://www.pacb.com/wp-content/uploads/PacBio-DNAnexus.pdf), and/or [FormBio](https://www.pacb.com/wp-content/uploads/FORM-Bio-flyer.pdf). 

# 1. Prerequisites
Before starting a tutorial, please make sure you have the following prerequisites completed. 

> ⚠️ **NOTE** ⚠️: you only need to run through this section **once**. After the initial setup, you can skip to [Tutorials](#tutorials)

## 1.1. Access NCShare 
### Create an Account
If you do not already have an account, please visit [NCShare](https://userguide.ncshare.org/guides/accountreg/) to request one.

### Access a terminal
If you have a Mac or Linux computer, you can use the native terminal app to access NCShare via SSH connection. If you have a Windows computer, you can download and use apps like [MobaXterm](https://mobaxterm.mobatek.net/) or [PuTTY](https://www.putty.org/) to access NCShare via SSH connection.

## 1.2. Setup SSH Key and Login
### Setup SSH Key
Follow the instructions to [setup an SSH key for NCShare Cluster Computing](https://userguide.ncshare.org/guides/setupssh/). 

Generate and View SSH Key
```
ssh-keygen -t ed25519

cat ~/.ssh/id_ed25519.pub
```

Add the SSH Key to [NCShare CoManage](https://ncshare-com-01.ncshare.org/registry): \
NCShare > My Profile > Authenticators > Add SSH Key


### Login to NCShare
```
ssh -i ~/.ssh/id_ed25519 username@login.ncshare.org
```

## 1.3. Download and Install Dependencies

### Download and install miniconda
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash ~/Miniconda3-latest-Linux-x86_64.sh

source ~/.bashrc

conda config --add channels bioconda
conda config --add channels conda-forge
conda config --show channels
```

### Install miniwdl and miniwdl-slurm extension
```
pip3 install miniwdl

pip3 install miniwdl-slurm
```

## 1.4. Create miniwdl configuration file
In the `miniwdl_setup` directory of this repository, I have included a sample miniwdl configuration file. You will need to place this file in your HOME directory: `~/.config/minidwdl.cfg`

The easiest solution is to clone this repository and move the file into it's final location.

``` 
git clone https://github.com/RhettRautsaw/PreMiEr_PacBio_tutorial

mkdir -p ~/.config

mv PreMiEr_PacBio_tutorial/miniwdl_setup/miniwdl.cfg ~/.config/miniwdl.cfg
```

## 1.5. Test miniwdl installation
To test the miniwdl installation and configuration file, I've also included a small WDL workflow that will scatter 10 jobs onto your HPC, call a base docker/singularity container, and generate 10 "hello_*.txt" files. We will tell miniwdl to run and place the results in `~/WHALE_POD_TEST`

```
miniwdl run PreMiEr_PacBio_tutorial/miniwdl_setup/whale_pod.wdl --dir ~/WHALE_POD_TEST
```

If you run this command a second time, it should complete much faster as it will locate the cached result from the previous successful run. 

# Tutorials

Now that you have completed the prerequisites, you are ready to start the tutorials! SSH into the NCShare compute cluster (if you are not already logged in).

```
ssh -i ~/.ssh/id_ed25519 username@login.ncshare.org
```

We have tutorials available for running the following workflows:
- [PacBio Metagenome Assembly (MAG) Pipeline](https://github.com/RhettRautsaw/PreMiEr_PacBio_tutorial/tree/main/MAG_Pipeline): Assemble and explore metagenomes
- [PacBio Metagenome Taxonomic Classification Pipeline](https://github.com/RhettRautsaw/PreMiEr_PacBio_tutorial/tree/main/TaxonomicProfiling_Pipeline): Use SourMash to profile taxonomic communities (STILL IN DEVELOPMENT)

<div style="display: flex; align-items: flex-start;">
  <img src="imgs/MAGWorkflow.png" width="75%" />
</div>

## Additional Workflows Available (no tutorials yet)

- Find more information, tools, and pipelines for HiFi metagenomics on [pb-metagenomics-tools](https://github.com/PacificBiosciences/pb-metagenomics-tools)

- Check out [SMRT Tools](https://www.pacb.com/support/software-downloads/) for additional workflows such as:
	- > **Note:** These can only be run with pbcromwell rather than miniwdl. Contact your PacBio FABS for additional support.
	- HiFi Target Enrichment Pipeline
	- Microbial Genome Analysis Pipeline
	- Kinnex Read Segmentation & Iso-Seq Analysis Pipeline
	- Kinnex Read Segmentation & single-cell Iso-Seq Analysis Pipeline
