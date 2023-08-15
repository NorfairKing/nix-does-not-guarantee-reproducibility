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

* Produce randomness 
* Have results that depend on multithreaded scheduling
