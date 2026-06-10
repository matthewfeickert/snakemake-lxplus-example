# snakemake-lxplus-example
Minimal Snakemake demonstrator for local execution and HTCondor submission on CERN lxplus/lxbatch.

## Overview

This repository demonstrates:

- local Snakemake execution with `pixi`
- HTCondor execution via `snakemake-executor-plugin-htcondor`
- writing to EOS from a batch job
- reading from EOS in a batch job and copying the result back into the workflow directory

The project uses a single `pixi` environment for both local and HTCondor runs.

It is intended for lxplus 9, but the local examples are otherwise generic. On CERN systems, it is recommended to run it from your work area rather than your home area, for example under `/afs/cern.ch/work/...`.

## Setup

### Install `pixi`

[Install `pixi`](https://pixi.sh/latest/#installation)

```
curl -fsSL https://pixi.sh/install.sh | bash
```

and also [enable the shell autocompletion](https://pixi.sh/latest/#autocompletion)

```
echo 'eval "$(pixi completion --shell bash)"' >> ~/.bashrc
```

and then restart shell or

```
. ~/.bash_profile
```

### Local example

```
pixi run example
```

If the environment is not installed yet, `pixi` will run the equivalent of
`pixi install` first. This example sorts `data/numbers.txt` into
`results/sorted_numbers_script.txt`.

### Optional apptainer example

```
pixi run apptainer-example
```

This runs the same kind of local workflow, but using the CERN CVMFS container
`/cvmfs/unpacked.cern.ch/registry.hub.docker.com/library/python:3.11` declared
in the Snakefile.

## Batching examples

For long-running workflows over many input files, a common pattern is to batch
multiple samples into one Snakemake job and size the HTCondor resource request
for that batch. This repository contains two local examples that simulate
per-sample cost with `sleep`.

The sample metadata lives in `data/batch_samples.tsv`, and the corresponding
dummy input files live under `data/batch_samples/`.

### Fixed-size batching

```
pixi run batch-fixed-example
```

This groups the sample list into fixed-size batches of three files per job. The
per-batch reports are written under `results/batching/fixed/`, with an overview
in `results/batching/fixed/summary.txt`.

This is the simplest approach, but it assumes that samples have roughly similar
cost. In the example data, that assumption is false, so some fixed batches end
up much heavier than others.

### Cost-aware batching

```
pixi run batch-balanced-example
```

This uses the expected per-sample runtime from `data/batch_samples.tsv` to pack
samples into batches with similar total cost. The per-batch reports are written
under `results/batching/balanced/`, with an overview in
`results/batching/balanced/summary.txt`.

This is closer to what you want when some samples are known to be slower than
others: keep each batch under a target total cost rather than forcing the same
number of files into every job.

Both batching examples set HTCondor-oriented resources in the Snakefile, so the
same pattern can be used for lxbatch submissions.

## HTCondor examples

Make sure you have a valid CERN Kerberos ticket (for example, `klist` should show a
current TGT), then run

```
pixi run lxbatch-example
```

This uses the native `snakemake-executor-plugin-htcondor` executor with the
workflow profile in `workflow/profiles/lxbatch/profile.v9+.yaml`.

This submits the rule `hello_lxbatch`, which writes `local_hello.txt` in the
workflow directory via HTCondor.

The lxbatch profile sets conservative HTCondor defaults for the demo:

- `htcondor_request_mem_mb=1024`
- `htcondor_request_disk_mb=1024`
- `classad_JobFlavour=espresso`

This means the examples request 1 GB memory, 1 GB disk, and the CERN batch
`espresso` job flavour (20 minutes maximum runtime). See the CERN batch docs on
[resources and limits](https://batchdocs.web.cern.ch/local/submit.html#resources-and-limits)
and [job flavours](https://batchdocs.web.cern.ch/local/submit.html#job-flavours).
For an exact wall-clock limit instead of a flavour bucket, use
`classad_MaxRuntime`.

For workflows where each job processes multiple input files, the batch size
should be chosen so that the worst-case total runtime and memory stay within the
requested HTCondor limits. The batching examples above illustrate two common
approaches:

- fixed-size batching when samples have similar cost
- cost-aware batching when some samples are known to run longer than others

This demonstrator has been verified on lxplus with the native executor plugin,
without the older cookiecutter profile, `cluster-generic` wrappers, or any
additional Kerberos staging helper.

To force a fresh submission, run

```
rm -f local_hello.txt
pixi run lxbatch-example --forcerun hello_lxbatch
```

## EOS examples

The EOS examples use `EOS_DIR` to point to a writable EOS directory, for example
`/eos/user/c/clange/snakemake-lxplus-example`.

### EOS write

This submits `hello_eos`, which writes `hello_from_htcondor.txt` directly into
`EOS_DIR`.

```
EOS_DIR=/eos/user/c/clange/snakemake-lxplus-example pixi run lxbatch-eos-example
```

To force a fresh submission, run

```
EOS_DIR=/eos/user/c/clange/snakemake-lxplus-example pixi run lxbatch-eos-example --forcerun hello_eos
```

Afterwards, verify the written EOS file with

```
cat /eos/user/c/clange/snakemake-lxplus-example/hello_from_htcondor.txt
```

### EOS read

This submits `read_eos`, which reads `hello_from_htcondor.txt` from `EOS_DIR`
and writes `results/read_from_eos.txt` in the repository.

```
EOS_DIR=/eos/user/c/clange/snakemake-lxplus-example pixi run lxbatch-eos-read-example
```

If `hello_from_htcondor.txt` is not present yet in `EOS_DIR`, Snakemake will first
run `hello_eos` to create it.

To force a fresh submission and overwrite the local result, run

```
rm -f results/read_from_eos.txt
EOS_DIR=/eos/user/c/clange/snakemake-lxplus-example pixi run lxbatch-eos-read-example --forcerun read_eos
```

Afterwards, verify the copied content with

```
cat results/read_from_eos.txt
```
