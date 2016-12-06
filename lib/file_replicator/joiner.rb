require 'pastel'
require 'ruby-progressbar'

require_relative 'joiner_cmd_parse'
require_relative 'replicator_helper'

module FileReplicator
  class Joiner
    include ReplicatorHelper

    def initialize
      @options = JoinerCmdParse.new.get_options
      @colour  = Pastel.new enabled: !@options[:no_colour]
    end

    def join
      files = Dir.glob(
          File.join(
              File.dirname(@options[:first]),
              '*'
          )
      ).sort

      prepare @options[:output_path]
      output_file = File.open @options[:output_path], 'ab'

      first_index = files.index File.expand_path(@options[:first])
      last_index  = files.index File.expand_path(@options[:last])

      if progress?
        file_pb = ProgressBar.create(
            total: (first_index..last_index).size,
            title: colour.bright_blue("#{File.basename output_file}")
        )
      end
      files[first_index..last_index].each do |file|
        File.open file, 'rb' do |f|
          while (data = f.read(READ_BUFFER))
            output_file.write data
          end
        end
        file_pb.increment if progress?
      end

      file_pb.finish if progress?
    rescue StandardError => e
      puts @colour.bright_red e.message unless quiet?
      file_pb.stop if progress?

      exit 1
    ensure
      output_file.close unless output_file.nil?
    end

  end
end
