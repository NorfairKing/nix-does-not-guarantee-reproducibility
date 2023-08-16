# Nix does not guarantee reproducibility

This repository serves to show that Nix does not guarantee that builds are reproducible **such that we may learn and improve our builds**.

Some of the following problems are not solvable.
In such a case there may be ways to mitigate them.
However, it is important that we **don't lie** about them when evangelising Nix.


What follows are examples of ways in which one might produce builds that nix does not guarantee reproducibility for.
More concrete definitions of "reproducibility" will be outlined as necessary.
Each counterexample will have a `[tag:` that points to a build that you can try out in this repository's flake.

## Reproducible successes

### Definition

A build is reproducibly successful if and only if "If it succeeds to builds once, it will always succeed to build." holds.

### Counterexamples

#### Resource no longer available

`[tag:unavailable_page]`

Fixed-output derivations produce the same result every time *if they succeed* (and hashing is not broken).
However, there's nothing to guarantee that the output can indeed be reproduced at all.
Sometimes resources on the internet become unavailable for reasons entirely beyond our control.

In this build, for example, we try to fetch a web page that is no longer available (a vine user profile).

```console
$ nix build .\#unreproduciblePackages.x86_64-linux.unavailablePage
error: unable to download 'https://vine.co/MyUserName': HTTP error 404
```

This build would have succeeded once upon a time, but will no longer succeed.


A real-world example of where this happens quite often is old versions of LaTeX libraries.
If you write a book in LaTeX and package it with nix, you need to keep the build up to date in order to be able to build the book again in the future.

One possible mitigation would be to use Nix' caching mechanism to make sure that you transparently cache all required resources in-house.
This can work as long as you can share this cache with anyone else who wants to perform the same build, and you don't even need to trust the cache because you have specified the hash of the result.

#### Random failure

`[tag:random_success]`

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
