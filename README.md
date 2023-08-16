# Nix does not guarantee reproducibility

This repository serves to show that Nix does not guarantee that builds are reproducible **such that we may learn and improve our builds**.

Some of the following problems are not solvable.
In such a case there may be ways to mitigate them.
However, it is important that we **don't lie** about them when evangelising Nix.


What follows are examples of ways in which one might produce builds that nix does not guarantee reproducibility for.
More concrete definitions of "reproducibility" will be outlined as necessary.
Each counterexample will have a `[tag:` that points to a build that you can try out in this repository's flake.



# Conclusion

The strongest claim I want to make about how Nix works is:

> Nix does the opposite of what you would do if you were deliberately trying to fuck things up.

In other words: Nix is the best chance I have to do builds in sane way.

Any claim similar to "Nix makes builds reproducible" or "You can rely on nix builds" are evidently (see below) _false_.



<sup>
<sub>
(I put the conclusion up here so that you wouldn't miss it at the bottom of this page.)
</sub>
</sup>

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
$ nix build .#unreproduciblePackages.x86_64-linux.unavailablePage
error: unable to download 'https://vine.co/MyUserName': HTTP error 404
```

This build would have succeeded once upon a time, but will no longer succeed.


A real-world example of where this happens quite often is old versions of LaTeX libraries.
If you write a book in LaTeX and package it with nix, you need to keep the build up to date in order to be able to build the book again in the future.

One possible mitigation would be to use Nix' caching mechanism to make sure that you transparently cache all required resources in-house.
This can work as long as you can share this cache with anyone else who wants to perform the same build, and you don't even need to trust the cache because you have specified the hash of the result.

#### Random failure

`[tag:random_success]`

When builds use randomness, whether they succeed or not may depend on that randomness.
In such a case, the build will sometimes fail where previously it would have passed.

In this build, for example, we access randomness to fail about half of the time:

``` console
$ nix build .#unreproduciblePackages.x86_64-linux.randomSuccess
error: builder for '/nix/store/p8a5a8fijg7qh464c0mvvh5yzndsx7vm-random-success.drv' failed with exit code 1
$ echo $?
1

$ nix build .#unreproduciblePackages.x86_64-linux.randomSuccess
$ echo $?
0
```
 
A real-world example of where this might happen is builds that run randomised property tests without a fixed seed.
Indeed when you run property tests, it is important to choose a fixed-seed in your builds.

Nix _could_ try mitigate this problem by not making randomness available to non-fixed-output derivations, but _should not_ do that because that would mean that nix builds could never generate secrets.
_Perhaps Nix could make a new type of alternative build for producing randomness so that this issue could be compartmentalised, but it is not clear if that would be an effective solution to any real problem._

## Reproducible failures

### Definition

A build fails reproducibly if and only if "If it fails to builds once, it will always fail to build." holds.

### Counterexamples

#### Benchmarks

`No example build yet.`

When (naively) running a benchmark in a nix build, and failing if the benchmarked software is not fast enough, you will find that the build succeeds (or not) depending on how powerful the build machine is.
Indeed, the build might pass on a beefy machine while failing on a laptop.

* Timing-related issues in benchmarks

A real-world example could be a (naive) benchmarking build that fails if the software that it builds is.

I don't know of any way that Nix might mitigate this issue.

#### Resource usage

`No example build, for ethical reasons.`

Some (all?) builds will fail if run on a machine with insufficient resources.
Indeed. Builds need some amount of memory and some amount of disk space to succeed.

Nix _could maybe_ mitigate this issue by learning about the resource requirements that builds have and fail early.
However, this could not fix the issue either because of the randomness problem outlined in a previous section.

## Reproducible results

### Definition

A build has reproducible results if and only if "If it succeeds to build, the result will be bit-for-bit identical to any other successful build".

You might think that a version of this definition could be "If it succeeds to build, the result will be practically equivalent to any other successful build".
However, adversarially speaking, this is not a weaker definition but instead an equivalent definition.

Indeed. It can never be clear whether a non-bit-for-bit-equal build is "functionally equivalent", so we *must* assume that they are not.

### Counterexamples

#### Producing randomness

`[tag:random_output]`

A build might produce randomness as part of its output.
As such, the output could be different across builds.

In the following build, a different number is produced every time, and we can see (with `--rebuild`) that Nix can tell that it's not a deterministic build:

``` console
$ nix build .\#unreproduciblePackages.x86_64-linux.randomOutput --rebuild
error: derivation '/nix/store/aisn9vhwqlkay45zj2p3v6h9yhjb6ll2-random-output.drv' may not be deterministic: output '/nix/store/s6y0k5kdmiwy6jrv7bqjgsgrhd21s2my-random-output' differs
```

A real-world example of this is a build that produces a test "secret" key.

Nix _could_ try mitigate this problem by not making randomness available to non-fixed-output derivations, but _should not_ do that because that could comprise a backdoor in builds.

#### Producing output based on multithreading

`[tag:multithreaded_output]`

Some builds produce different output based on how threads are scheduled.
The GHC Haskell compiler does this, for example.
The following is a build of a Haskell package (just about any Haskell package will do):

``` console
$ nix build .\#unreproduciblePackages.x86_64-linux.multithreadedOutput --rebuild
error: derivation '/nix/store/iqxgnqjm57qpfxnlncghirapqm6gg0y8-validity-0.12.0.1.drv' may not be deterministic: output '/nix/store/ibkkj6xxdhdgw3rn1bs6iizyq6ivq0jx-validity-0.12.0.1' differs
```

This is [a longstanding GHC issue](https://gitlab.haskell.org/ghc/ghc/-/issues/12935) and not at all unique to GHC.
As long as [GHC is bug-free](https://gitlab.haskell.org/ghc/ghc/-/issues/), this *shouldn't* matter for results.

Nix *could* mitigate this issue by running all builds on a single core, but that *should not* because that would slow down builds massively.
It also wouldn't necessarily help because running a build on one core does not prevent GHC from spawning multiple green threads anyway.
