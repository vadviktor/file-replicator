require 'pastel'
require 'slop'

require_relative 'exceptions'
require_relative 'version'

module FileSplitJoinBinary
  class SplitterCmdParse

    def initialize
      @pastel = Pastel.new
    end

    def parse
      options = Slop.parse do |o|
        o.string '-f', '--files', "Files to split, Ruby's Dir.glob style"
        o.string '-o', '--output-dir', 'Destination directory, (default: current directory)', default: '.'
        o.string '-p', '--patterns', 'Output file pattern, details in the --readme (default: {orf}.{onu})', default: '{orf}.{onu}'
        o.integer '-s', '--size', 'Max size of split elements, details in the --readme'
        o.integer '-e', '--elements', 'Number of parts to split into'
        o.string '--checksum', 'Create checksum with the specified algorithm'
        o.bool '--no-progress', 'Disable progressbar'
        o.bool '--no-colour', 'Disable colours'
        o.bool '--quiet', 'Suppress output'

        o.on('--readme', 'Detailed description of some of the parameters and exit') {
          puts readme
          exit
        }

        o.on('--version', 'Display version information and exit') {
          puts VERSION
          exit
        }

        o.on('--help', 'Display this message') {
          puts o
          exit
        }
      end

      validate options

      options
    rescue MissingArgumentException,
        ArgumentValueException,
        Slop::MissingArgument,
        Slop::UnknownOption => e
      puts @pastel.red e.message
    end

    protected

    def validate(options)
      unless options.files?
        msg = 'Missing list of files to operate on (-f)'
        raise MissingArgumentException.new msg
      end

      unless options.size?
        msg = 'Missing the size or number of elements to split files into (-s or -e)'
        raise MissingArgumentException.new msg
      end

      if options.size? and options.elements?
        msg = 'Choose either size or number of elements (-s or -e)'
        raise ConflictingArgumentsExceptions.new msg
      end

      if options.size? and options.size.match(/^[\d]+(k|m|g)?$/i)
        msg = "#{options.size} is not an acceptable format for size"
        raise ArgumentValueException.new msg
      end

      if options.checksum? and !Checksum::SUPPORTED.include?(
          options.checksum.downcase.to_sym)
        msg = "#{options.checksum} is not a supported checksum algorithm"
        raise ArgumentValueException.new msg
      end
    end

    def readme
      output = <<-TXT
  %{output_file_patterns}

    Use these building blocks to extract, reuse and add parts to construct output filenames.
    The patterns are case insensitive and the surroing curly braces are part of them (see example).

    %{ord} - Original, absolute directory
    %{orf} - Original filename, with extension
    %{ore} - File's (last) extension
    %{orb} - File's name without it's extension
    %{num} - Incremental numbers starting at 1: [1, 2, 3, ...]
    %{onu} - Incremental numbers starting at 1 and padded with zeros: [01, 02, ... 10, 11]


  %{output_file_sizes}

    By default the number used as a file size is in bytes.
    We can use a more human readable form to specify larger amounts:
      e.g.: 256k => 256 kilobytes

    Suffixes:
      - k => kilobyte
      - m => megabyte
      - g => gigabyte


  %{checksum_header}
    - md5 (considered broken)
    - sha1 (considered broken)
    - sha224
    - sha256
    - sha384
    - sha512

      TXT

      output % {
          output_file_patterns: @pastel.yellow.bold.underline('Output file patterns:'),
          output_file_sizes:    @pastel.yellow.bold.underline('Output file sizes:'),
          checksum_header:      @pastel.yellow.bold.underline('Supported checksum algorithms:'),
          ord:                  @pastel.green.bold('{ord}'),
          orf:                  @pastel.green.bold('{orf}'),
          ore:                  @pastel.green.bold('{ore}'),
          orb:                  @pastel.green.bold('{orb}'),
          num:                  @pastel.green.bold('{num}'),
          onu:                  @pastel.green.bold('{onu}')
      }
    end

  end
end
