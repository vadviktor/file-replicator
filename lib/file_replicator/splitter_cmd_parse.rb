require 'pastel'
require 'slop'

require_relative 'checksum'
require_relative 'exceptions'
require_relative 'version'

module FileReplicator
  class SplitterCmdParse

    attr_reader :colour

    def initialize
      @colour = Pastel.new
    end

    def get_options
      options = parse_argv

      # display parameter list to let user know how to use them
      if ARGV.empty?
        puts options
        exit
      end

      validate options

      options
    rescue MissingArgumentException,
        ArgumentError,
        Slop::MissingArgument,
        Slop::UnknownOption => e
      puts colour.bright_red e.message
      exit 1
    end

    protected

    # Parse ARGV
    # @return Slop options
    def parse_argv
      Slop.parse do |o|
        o.string '-f', '--files', "Files to split, Ruby's Dir.glob style"
        o.string '-o', '--output-dir', 'Destination directory, (default: current directory)', default: '.'
        o.string '-p', '--pattern', 'Output file pattern, details in the --readme (default: {orf}.{onu})', default: '{orf}.{onu}'
        o.string '-s', '--size', 'Max size of split elements, details in the --readme'
        o.integer '-e', '--elements', 'Number of parts to split into'
        o.string '-m', '--min-size', 'Minimal size threshold of a file to consider splitting, details in the --readme'
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

        o.on('-h', '--help', 'Display this message') {
          puts o
          exit
        }
      end
    end

    def validate(options)
      validate_files options
      validate_directory options
      validate_unknown_split_size options
      validate_conflicting_split_size options
      validate_size_format options
      validate_minimal_size options
      validate_checksum options
    end

    # Validates checksum algorithm
    # @param [Slop] options
    # @raise ArgumentError
    def validate_checksum(options)
      if options.checksum? and !Checksum::SUPPORTED.include?(
          options[:checksum].downcase.to_sym)
        msg = "#{options[:checksum]} is not a supported checksum algorithm"
        raise ArgumentError.new msg
      end
    end

    # Validates minimal size's format
    # @param [Slop] options
    # @raise ArgumentError
    def validate_minimal_size(options)
      if options.min_size? && !options[:min_size].match(/^[\d]+(k|m|g)?$/i)
        msg = "#{options[:min_size]} is not an acceptable format for minimal size"
        raise ArgumentError.new msg
      end
    end

    # Validates size's format
    # @param [Slop] options
    # @raise ArgumentError
    def validate_size_format(options)
      if options.size? && !options[:size].match(/^[\d]+(k|m|g)?$/i)
        msg = "#{options[:size]} is not an acceptable format for split size"
        raise ArgumentError.new msg
      end
    end

    # Check if only either size or number of elements options are used
    # @param [Slop] options
    # @raise ConflictingArgumentsExceptions
    def validate_conflicting_split_size(options)
      if options.size? and options.elements?
        msg = 'Choose either size or number of elements (-s or -e)'
        raise ConflictingArgumentsExceptions.new msg
      end
    end

    # Check if size or number of elements options are set
    # @param [Slop] options
    # @raise MissingArgumentException
    def validate_unknown_split_size(options)
      unless options.size? or options.elements?
        msg = 'Missing the size or number of elements to split files into (-s or -e)'
        raise MissingArgumentException.new msg
      end
    end

    # Validates the existence of files
    # @param [Slop] options
    # @raise MissingArgumentException
    def validate_files(options)
      unless options.files?
        msg = 'Missing list of files to operate on (-f)'
        raise MissingArgumentException.new msg
      end
    end

    # Validates the existence of a directory
    # @param [Slop] options
    # @raise ArgumentError
    def validate_directory(options)
      unless options.output_dir?
        msg = 'Missing output path (-o)'
        raise MissingArgumentException.new msg
      end

      unless File.directory? options[:output_dir]
        msg = "#{options[:output_dir]} does not look like a directory (-o)"
        raise ArgumentError.new msg
      end
    end

    def header(txt)
      colour.yellow.bold.underline txt
    end

    def highlight(txt)
      colour.green.bold txt
    end

    def readme
      <<-TXT
  #{header 'Output file patterns:'}

    Use these building blocks to extract, reuse and add parts to construct output filenames.
    The patterns are case insensitive and the surroing curly braces are part of them (see example).

    #{highlight '{ord}'} - Original, absolute directory
    #{highlight '{orf}'} - Original filename, with extension
    #{highlight '{ore}'} - File's (last) extension
    #{highlight '{orb}'} - File's name without it's extension
    #{highlight '{num}'} - Incremental numbers starting at 1: [1, 2, 3, ...]
    #{highlight '{onu}'} - Incremental numbers starting at 1 and padded with zeros: [01, 02, ... 10, 11]


  #{header 'Output file sizes:'}

    By default the number used as a file size is in bytes.
    We can use a more human readable form to specify larger amounts:
      e.g.: 256k => 256 kilobytes

    Suffixes:
      - #{highlight 'k'} => kilobyte
      - #{highlight 'm'} => megabyte
      - #{highlight 'g'} => gigabyte

  #{header 'Minimal file sizes:'}
    
    This option allows us to set a minimal size threshold for files.
    Files smaller than this threshold will be skipped.
    We can use a more human readable form to specify larger amounts just like for output sizes.

  #{header 'Supported checksum algorithms:'}
    - #{highlight 'md5'} #{colour.cyan '(considered broken)'}
    - #{highlight 'sha1'} #{colour.cyan '(considered broken)'}
    - #{highlight 'sha224'}
    - #{highlight 'sha256'}
    - #{highlight 'sha384'}
    - #{highlight 'sha512'}

      TXT
    end

  end
end
