# snakemake-lxplus-example
Snakemake hello world example on LXPLUS and lxbatch

## Setup

This is for LXPLUS 9 but it should be location independent.
However, as the LXPLUS home areas have limited storage, it is recommended that you run this example under your work (e.g. `/afs/cern.ch/work/f/feickert`) directory.

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

### Run example

```
pixi run example
```

If you haven't installed the environment yet, `pixi` will run the equivalent of `pixi install` before executing your `pixi run` command.


### Trivial lxbatch example

```
pixi run lxbatch-example
```
