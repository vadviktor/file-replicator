require 'pastel'
require 'ruby-progressbar'

require_relative 'checksum'
require_relative 'replicator_helper'
require_relative 'splitter_cmd_parse'

module FileReplicator
  class Splitter
    include ReplicatorHelper

    def initialize
      @options = SplitterCmdParse.new.get_options
      @colour  = Pastel.new enabled: !@options[:no_colour]

      if (alg = @options.to_h.fetch(:checksum, false))
        @checksum = Checksum.new alg
      end
    end

    def split
      file_no = 0
      files   = Dir.glob(File.expand_path(options[:files])).sort
      files.each do |file_name|
        file_no       += 1
        file_abs_path = File.expand_path(file_name)
        file_size     = File.size(file_abs_path)

        next if options.min_size? and file_size < size_in_bytes(options[:min_size])

        if options.size?
          split_size         = size_in_bytes options[:size]
          number_of_elements = (file_size.to_f / split_size).ceil
        elsif options.elements?
          split_size         = (file_size.to_f / options[:elements]).ceil
          number_of_elements = options[:elements]
        end

        if progress?
          file_pb = ProgressBar.create(
              total: number_of_elements,
              title: colour.bright_blue("#{File.basename file_name}")
          )
        end

        @checksum.start_new_file File.join(options[:output_dir],
                                           File.basename(file_name)) if chksum?

        File.open file_abs_path, 'rb' do |f|
          file_split_no = 0

          until f.eof? or f.closed?
            file_split_no    += 1
            output_file_path = File.join(
                options[:output_dir],
                self.class.pattern_to_path(
                    options[:pattern],
                    file_path:    file_abs_path,
                    file_number:  file_no,
                    chunk_number: file_split_no,
                    max_elements: number_of_elements
                ))

            prepare output_file_path

            bytes_written = 0
            begin
              # write to chunk file
              @checksum.start_new_chunk output_file_path if chksum?
              split_file = File.open output_file_path, 'ab'
              while bytes_written <= split_size and (data = f.read(READ_BUFFER))
                split_file.write data
                bytes_written += READ_BUFFER
                @checksum.add_chunk data if chksum?
              end
            rescue StandardError => e
              puts colour.bright_red e.message unless quiet?
              f.close
              file_pb.stop if progress?
              exit 1
            ensure
              split_file.close unless split_file.nil?
              file_pb.increment if progress?
              @checksum.append_chunk_checksum if chksum?
            end
          end
        end

        file_pb.finish if progress?
        @checksum.append_file_checksum if chksum?

      end

    end

    protected

    def self.pattern_to_path(pattern, file_path: nil, chunk_number: nil,
        max_elements: nil, file_number: nil)
      # Patterns:
      # {ord} - Original, absolute directory
      # {orf} - Original filename, with extension
      # {ore} - File's (last) extension with the lead dot: .jpg
      # {orb} - File's name without it's extension
      # {num} - Incremental numbers starting at 1: [1, 2, 3, ...]
      # {onu} - Incremental numbers starting at 1 and padded with zeros: [01, 02, ... 10, 11]
      # {gcn} - Incremental numbers starting at 1: [1, 2, 3, ...], used in multi file scenario

      unless file_path.nil?
        pattern = pattern.gsub(/\{ord\}/i, '%{ord}') % {
            ord: File.dirname(file_path) }

        pattern = pattern.gsub(/\{orf\}/i, '%{orf}') % {
            orf: File.basename(file_path) }

        pattern = pattern.gsub(/\{ore\}/i, '%{ore}') % {
            ore: File.extname(file_path) }

        pattern = pattern.gsub(/\{orb\}/i, '%{orb}') % {
            orb: File.basename(file_path, File.extname(file_path)) }
      end

      pattern = pattern.gsub(/\{num\}/i, '%{num}') % {
          num: chunk_number } unless chunk_number.nil?

      pattern = pattern.gsub(/\{gcn\}/i, '%{gcn}') % {
          gcn: file_number } unless file_number.nil?

      unless chunk_number.nil? and max_elements.nil?
        padded_num = chunk_number.to_s.rjust max_elements.to_s.length, '0'
        pattern    = pattern.gsub(/\{onu\}/i, '%{onu}') % { onu: padded_num }
      end

      # keep the path clean and valid
      pattern.gsub "#{File::SEPARATOR}#{File::SEPARATOR}", File::SEPARATOR
    end

    def size_in_bytes(size_string)
      case size_string[-1].downcase
        when 'k'
          size_string.to_i * 1024
        when 'm'
          size_string.to_i * 1024**2
        when 'g'
          size_string.to_i * 1024**3
        else
          size_string.to_i
      end
    end

  end
end
