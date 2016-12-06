require 'fileutils'

module FileReplicator
  module ReplicatorHelper
    READ_BUFFER = 256 * 1024

    attr_reader :options, :colour, :checksum

    protected

    def prepare(file_path)
      FileUtils.mkdir_p File.dirname(file_path)
      FileUtils.rm_f file_path
      FileUtils.touch file_path
    end

    def quiet?
      options.quiet?
    end

    def progress?
      !options.no_progress? && !quiet?
    end

    def chksum?
      !checksum.nil? && !quiet?
    end
  end
end