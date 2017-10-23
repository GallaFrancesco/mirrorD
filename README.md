# mirrorD

mirrorD aims to be a simple, decentralized and automated way of managing mirrors of local directories in a distributed environment.

## State of development

Right now the project is at the early stages of development.
### What has been done so far:
* Tree data structure capable of scanning, loading and mantaining status of a directory (root) and its subdirectories;
* Timed reload of the directory structure(s) previously loaded;
* Status of files inside a directory, based on: **time of last modification** and **file hashing**. Digest algorithms used for hashing can be chosen between SHA256 *(default)*, SHA1, CRC32, MurmurHash (32 and 64, automatically chosen depending on system architecture);
* command line and config file parsing (powered by [burner/argsd](https://github.com/burner/argsd)).
* basic webserver (only on localhost)
* interactive directory creation on startup, to ease the process of managing configurations.

### What is currently been developed:
* A well designed REST API, which is going to be used for communication between each mirrorD instance running on HTTP;
* A proper design for file sinchronization, optimized for large directories.

### What has yet to be done (meaning, not a priority right now but will be):
* Authentication and security protocols, which have to be integrated with the server;
* Web interface

## Installation

The project has to be built with dub. Clone the repo, then build it with: 

```
user@/path/to/repo$ dub
```
This should automatically download the missing dependencies, build the project and start it with the [default configuration](#Defaults).

#### Defaults

The default configuration is only for testing purposes.
To test mirrorD, navigate to the repository directory, then:

```
user@/path/to/repo$ mkdir -p test/testfile
user@/path/to/repo$ ./mirrord
```
#### CLI arguments

Command line arguments are very few at the moment:

* `-f` or `--directory` allows the user to select a directory 
* `-d` or `--digest` allows the user to select a digest algorithm (sha1, sha256, crc32, mmhash)

#### Performance note

**Large directories could take a while to load, especially with the SHA256 digest selected**. 
With CRC32 (fastest), I tested 20 GB of data processed in 15 minutes on my laptop's i7 processor. Performance highly depends on hardware architecture though, so I advise to run proper tests. A good way of benchmarking mirrorD's performance is the Linux command `time`:

```
time -p ./mirrord -f [folder] -d [digest]
```
If instead one prefers to benchmark directly the hashing performance of its machine, I recommend the `shasum` command (only for SHA digests):

```
sha1sum [file]
sha256sum [file]
```
SHA1 performance should be comparable to CRC32, although a bit slower. SHA256 is significantly slower than all of the others.

*Have fun!*
