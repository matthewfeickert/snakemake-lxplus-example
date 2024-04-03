# snakemake-lxplus-example
Snakemake hello world example on LXPLUS and lxbatch

## Setup

This is for LXPLUS 9 but it should be location independent.

### Install `pixi`

[Install `pixi`](https://pixi.sh/latest/#installation)

```
curl -fsSL https://pixi.sh/install.sh | bash
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
