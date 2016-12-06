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

* For the examples below take the following structure:

```
$ tree -h /mnt
/mnt/
├── [   0]  rugby
│   └── [1.1G]  match.mkv
├── [ 43M]  tv1.mkv
├── [ 94M]  tv2.mkv
└── [103M]  tv3.mkv
```

* Split one file into 3 parts and store them in `/opt`:

```
$ rsplit -f /mnt/rugby/match.mkv -o /opt -e 3
```
    
* To split more files you can use [Ruby's Dir.glob patterns](https://ruby-doc.org/core-2.3.0/Dir.html#method-c-glob):
```    
$ rsplit -f "/mnt/tv*.mkv"
```
    
will match tv1.mvk, tv2.mkv and tv3.mkv too.    

**NOTE**: to avoid shells' path pattern translation you have to put the pattern in between quotes.

* Whenever you wish to split many files with mixed sizes, where there are a few files just too small you wish not to process you can use the `--min-size` option.

So let's exclude any file that is just smaller than 50 megabytes:  

```
$ rsplit rsplit -f "/mnt/tv*.mkv" -m 50m
```

will match tv2.mkv and tv3.mkv and NOT tv1.mkv which is only 43M small.

* Apart from controlling the destination folder you may not want to rename the source file(s) just to get the expected output chunk files. This is where the output file name `--pattern` option come in play.

Use these building blocks to extract, reuse and add parts to construct output filenames.
The patterns are case insensitive and the surrounding curly braces are part of them (see example).

    {ord} - Original, absolute directory
    {orf} - Original filename, with extension
    {ore} - File's (last) extension with the lead dot: .jpg
    {orb} - File's name without it's extension
    {num} - Incremental numbers starting at 1: [1, 2, 3, ...]
    {onu} - Incremental numbers starting at 1 and padded with zeros: [01, 02, ... 10, 11]
    {gcn} - Incremental numbers starting at 1: [1, 2, 3, ...], used in multi file scenario

  E.g. you want to rename every file to a fixed name with a zero prefixed number prefix:
   
```
  $ rsplit -f "/mnt/**/*.mkv" -p {onu}_tv-match-{gcn}.mkv
```

will name the split files like:

```
1_tv-match-1.mkv
2_tv-match-1.mkv
1_tv-match-2.mkv
2_tv-match-2.mkv
```

**NOTE**:
  - You MUST use `{gcn}` in your file name as it will count the main files, so you will still be able to distinguish files.
  - Files, when gathered according the Dir.glob pattern will be then sorted by the default sort algorithm for Ruby Arrays. That is going to affect how the files are going to be numbered by `{gcn}`.

### Joinging files

Joining file chunks is a more basic operation with less options.
Basically the supplied `rjoin` command is really just a little bit boosted linux `cat`.

YOu are able to combine a list of files in alphabetical order (as far as Ruby's Array#sort goes) by just defining the first and last file, and rjoin will get the file in between:

    $ rjoin -f file.bin.001 -l file.bin.125 -o file.bin
    
will join the 125 chunks into file.bin. Work pretty good because the numbering is zero prefixed and alphabetical sorting will do it's job as you expect.

## Todo list

- [ ] Write a nice `--readme` for `rjoin`
- [ ] Do checksum verification upon joining
- [ ] Figure out more tests

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vadviktor/whatever. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct. 

1. Fork it (https://github.com/vadviktor/file-replicator/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
