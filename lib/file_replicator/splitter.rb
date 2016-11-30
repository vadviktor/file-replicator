require 'digest'
require 'fileutils'

require 'pastel'
require 'ruby-progressbar'

require_relative 'splitter_cmd_parse'

module FileReplicator

  class Splitter
    READ_BUFFER = 256 * 1024

    attr_reader :files, :options, :colour, :digest

    def initialize
      @options = SplitterCmdParse.new.get_options
      @colour  = Pastel.new enabled: !options[:no_colour]
      @files   = Dir.glob File.expand_path(options[:files])

      if (alg = options.to_h.fetch(:checksum, false))
        @digest = Digest.const_get(alg.upcase).new
      end
    end

    def split
      files.each do |file_name|
        file_abs_path = File.absolute_path(File.expand_path(file_name))
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

        output_file_pattern = pattern_to_path options[:pattern], file_path: file_abs_path

        File.open file_abs_path, 'rb' do |f|
          file_split_no = 0
          until f.eof? or f.closed?
            output_file_path = File.join(
                options[:output_dir],
                pattern_to_path(
                    output_file_pattern,
                    number:       file_split_no,
                    max_elements: number_of_elements
                )
            )
            prepare output_file_path

            file_split_no += 1
            bytes_written = 0
            begin
              split_file = File.open output_file_path, 'ab'
              while bytes_written <= split_size and (data = f.read(READ_BUFFER))
                split_file.write data
                bytes_written += READ_BUFFER
                digest << data if chksum?
              end
            rescue StandardError => e
              puts colour.bright_red e.message unless quiet?
              f.close
              file_pb.stop if progress?
              exit 1
            ensure
              split_file.close unless split_file.nil?
              file_pb.increment if progress?
              digest.reset if chksum?
            end
          end
        end

        file_pb.finish if progress?

        puts "Checksum: #{colour.white.on_black digest.hexdigest}" if chksum?

      end

    end

    protected

    def prepare(file_path)
      FileUtils.mkdir_p File.dirname(file_path)
      FileUtils.rm_f file_path
    end

    def quiet?
      options.quiet?
    end

    def progress?
      !options.no_progress? && !quiet?
    end

    def chksum?
      !digest.nil? && !quiet?
    end

    def pattern_to_path(pattern, file_path: nil, number: nil, max_elements: nil)
      # Patterns:
      # {ord} - Original, absolute directory
      # {orf} - Original filename, with extension
      # {ore} - File's (last) extension
      # {orb} - File's name without it's extension
      # {num} - Incremental numbers starting at 1: [1, 2, 3, ...]
      # {onu} - Incremental numbers starting at 1 and padded with zeros: [01, 02, ... 10, 11]

      unless file_path.nil?
        pattern = pattern.gsub(/\{ord\}/, '%{ord}') % { ord: File.dirname(file_path) }
        pattern = pattern.gsub(/\{orf\}/, '%{orf}') % { orf: File.basename(file_path) }
        pattern = pattern.gsub(/\{ore\}/, '%{ore}') % { ore: File.extname(file_path) }
        pattern = pattern.gsub(/\{orb\}/, '%{orb}') % { orb: File.basename(file_path, File.extname(file_path)) }
      end

      pattern = pattern.gsub(/\{num\}/, '%{num}') % { num: number } unless number.nil?

      unless number.nil? and max_elements.nil?
        padded_num = number.to_s.rjust max_elements.to_s.length, '0'
        pattern    = pattern.gsub(/\{onu\}/, '%{onu}') % { onu: padded_num }
      end

      pattern
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
