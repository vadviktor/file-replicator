require 'pastel'
require 'slop'

require_relative 'checksum'
require_relative 'exceptions'
require_relative 'version'

module FileReplicator
  class AbstractCmdParse

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
      puts @colour.bright_red e.message
      exit 1
    end

    def header(txt)
      @colour.yellow.bold.underline txt
    end

    def highlight(txt)
      @colour.green.bold txt
    end

    def parse_argv
      raise 'Implementation missing'
    end

    def validate(options)
      raise 'Implementation missing'
    end

  end
end