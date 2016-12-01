require 'digest'

module FileReplicator
  class Checksum

    SUPPORTED = [:md5, :sha1, :sha224, :sha256, :sha384, :sha512]

    def initialize(alg)
      @alg          = alg
      @file_digest  = Digest.const_get(alg.upcase).new
      @chunk_digest = Digest.const_get(alg.upcase).new
    end

    def add_chunk(data)
      @chunk_digest << data
      @file_digest << data
    end

    def start_new_file(file_path)
      @file_path = file_path
      @file_digest.reset
    end

    def start_new_chunk(chunk_file_name)
      @chunk_file_name = File.basename(chunk_file_name)
      @chunk_digest.reset
    end

    def append_chunk_checksum
      append_to_checksum_file @chunk_digest.hexdigest, @chunk_file_name
    end

    def append_file_checksum
      append_to_checksum_file @file_digest.hexdigest, @file_path
    end

    protected

    def append_to_checksum_file(hexdigest, checksummed_file_path)
      raise 'No checksum file path is defined' if @file_path.nil?

      chk_filename = "#{@file_path}.#{@alg.downcase}"
      File.open chk_filename, 'a' do |f|
        f.write "#{hexdigest}  #{File.basename(checksummed_file_path)}\n"
      end
    end

  end
end