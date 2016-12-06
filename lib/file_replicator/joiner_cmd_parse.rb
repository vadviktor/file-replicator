require_relative 'abstract_cmd_parse'

module FileReplicator
  class JoinerCmdParse < AbstractCmdParse

    protected

    # Parse ARGV
    # @return Slop options
    def parse_argv
      Slop.parse do |o|
        o.string '-f', '--first', 'First file of the list to combine'
        o.string '-l', '--last', 'Last file of the list to combine'
        o.string '-o', '--output-path', 'Destination file path'
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
      validate_first_file options
      validate_last_file options
    end

    def validate_first_file(options)
      unless options.first?
        msg = 'Missing first input file (-f)'
        raise MissingArgumentException.new msg
      end

      unless File.exist? options[:first]
        msg = "#{options[:first]} does not exist (-f)"
        raise ArgumentError.new msg
      end
    end

    def validate_last_file(options)
      unless options.last?
        msg = 'Missing last input file (-l)'
        raise MissingArgumentException.new msg
      end

      unless File.exist? options[:last]
        msg = "#{options[:last]} does not exist (-l)"
        raise ArgumentError.new msg
      end
    end

    # Validates the existence of a directory
    # @param [Slop] options
    # @raise ArgumentError
    def validate_directory(options)
      unless options.output_path?
        msg = 'Missing output path (-o)'
        raise MissingArgumentException.new msg
      end
    end

    def readme
      <<-TXT
README
      TXT
    end

  end
end


