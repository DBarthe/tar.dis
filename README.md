tar.dis
=======
Inspired by the Gallifrey's technology, tar.dis is a file format that allows loseless data compression, and (will) uses tar as archiver.


# How to


### Clone
```bash
$ git clone --recursive git@github.com:DBarthe/tar.dis.git
```
>or
```bash
$ git clone git@github.com:DBarthe/tar.dis.git
$ git submodule init
$ git submodule update
```

### Compile

You need the 4.02.1 version of ocaml. To get it :
```bash
$ opam switch 4.02.1
$ eval `opam config env`
```
then,
```bash
$ make      # for ocaml byte-code
$ make nc   # for native and more efficient code
```

### Use
```bash
$ ./tardis -help
usage: ./tardis [-c|-d] [-f output_file ] input_file
  -c      compression mode (default)
  -d      decompression mode
  -f      optional output file
  -help   Display this list of options
```

##### Examples :

###### small syntax
```bash
$ ./tardis foobar             # compress
$ ./tardis -d foobar.tar.dis  # decompress
```

###### more options
```bash
$ ./tardis -c -f foobar.tar.dis foobar    # compress
$ ./tardis -d -f foobar foobar.tar.dis    # decompress
```
