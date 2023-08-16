# Nix does not guarantee reproducibility

This repository serves to show that Nix does not guarantee that builds are reproducible *such that we may learn and improve our builds*.


## Reproducible successes

### Definition

A build is reproducibly successful if and only if "If it succeeds to builds once, it will always succeed to build." holds.

### Counterexample

* Get data from a no-longer-available resource: `[tag:unavailable_page]`

```console
$ nix build .\#unreproduciblePackages.x86_64-linux.unavailablePage
error: unable to download 'https://vine.co/MyUserName': HTTP error 404
```

* Get data from randomness: `[tag:random_success]`

This build sometimes fails and sometimes passes:

```
$ nix build .\#unreproduciblePackages.x86_64-linux.randomSuccess
```


## Reproducible failures

### Definition

A build fails reproducibly if and only if "If it fails to builds once, it will always fail to build." holds.

### Counterexample

* Have builds occasionally use _much_ more memory

## Reproducible results

### Definition

A build has reproducible results if and only if "If it succeeds to build, the result will be bit-for-bit identical to any other successful build".

(You might think that a version of this definition could be "If it succeeds to build, the result will be practically equivalent to any other successful build".
However, adversarially speaking, this is not a weaker definition but an equivalent definition.)

### Counterexample

* Produce randomness: `[tag:random_output]`

``` console
$ nix build .\#unreproduciblePackages.x86_64-linux.randomOutput --rebuild
error: derivation '/nix/store/aisn9vhwqlkay45zj2p3v6h9yhjb6ll2-random-output.drv' may not be deterministic: output '/nix/store/s6y0k5kdmiwy6jrv7bqjgsgrhd21s2my-random-output' differs
```

* Have results that depend on multithreaded scheduling

``` console
$ nix build .\#unreproduciblePackages.x86_64-linux.multithreadedOutput --rebuild
error: derivation '/nix/store/iqxgnqjm57qpfxnlncghirapqm6gg0y8-validity-0.12.0.1.drv' may not be deterministic: output '/nix/store/ibkkj6xxdhdgw3rn1bs6iizyq6ivq0jx-validity-0.12.0.1' differs
```

GHC is not deterministic because its output depends on how threads were scheduled during compilation.
