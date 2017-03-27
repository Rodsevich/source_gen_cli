![Generator+ logo](./logo.png "Generator +")
# source_gen_cli

Have you ever tried using or extending [source_gen](https://github.com/dart-lang/source_gen)? Did you see how tedious it was at first? Have you fought again with it in another project when you needed it again?

This utility library for [source_gen](https://github.com/dart-lang/source_gen) tries to solve those problems, with additions on creating easily your own generators in a uniform way.

## Installation

Requirements:

To install:

```console
> pub global activate source_gen
```

To update, run activate again:

```console
> pub global activate source_gen
```

## Generators Usage

```console
> source_gen path/to/file1.dart path/to/file2.dart path/to/directory
```
Will process _file1.g.dart_, _file2.g.dart_ and all the generation demanding files of _/path/to/directory_.

As that command is tedious, you should create a *source_gen.yaml* that avoids you the need of including those params. As doing that is tedious too, here you have the command:

```console
> source_gen config-file
```

That configuration file will make your life easier in many ways, including the avoiding of those params previously written.

```console
> source_gen #Build the desired generated code
> source_gen --watch #Watch for file editions and rebuild 'em
```

## Generators Generation

Like with [stagehand](https://github.com/google/stagehand), here you could create your own Generator repo in a standarized way that helps this package detect its generators. Just create your generator's dir and scaffold:

```console
> mkdir MyGenerator
> source_gen new generator_package
```

But this package would be a contradiction if it wouldn't include generations for more code apart from the starting one. So here you have the command for those _Generator's generation_:

```console
> source_gen add generator
```
