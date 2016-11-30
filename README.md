# :construction: This gem is not released yet :exclamation:

# File replicator, a split-join command line tool

This Gem provides you with two command line tools, one to split up files and one to join them back togather again.
Splitting operation is binary only, making it mostly suitable for files like huge images, videos, archive formats, etc. Since it is binary it should not have any problems splitting and then joining text files, just mind that it can break reading part files as they may loose line ending info until they are joined.

## Features

- progress bar per file
- checksum algorithms: md5, sha1, sha224, sha256, sha318, sha512


## Installation

    gem install file-replicator

If you are using [rbenv](https://github.com/rbenv/rbenv), don't forget to `rehash` to pick up new executables:

    rbenv rehash

## Usage

### Splitting files

To split files use the `rsplit` command. When it is used without arguments it will print it's parameter list:
    
```
$ rsplit
usage: rsplit [options]
    -f, --files       Files to split, Ruby's Dir.glob style
    -o, --output-dir  Destination directory, (default: current directory)
    -p, --pattern     Output file pattern, details in the --readme (default: {orf}.{onu})
    (...truncated...)
```

There is a built in, very valuable `manual` with the `--readme` parameter:

    $ rsplit --readme

#### Examples

For the examples below take the following structure:

```
$ tree -h /mnt
/mnt/
├── [   0]  rugby
│   └── [1.1G]  match.mkv
├── [ 43M]  tv1.mkv
├── [ 94M]  tv2.mkv
└── [103M]  tv3.mkv
```

Split one file into 3 parts and store them in `/opt`:

    $ rsplit -f /mnt/rugby -o /opt -e 3

### Joinging files

    TODO

## Development

    TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vadviktor/whatever. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct. 

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
