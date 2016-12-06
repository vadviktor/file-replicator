require_relative '../test_helper'

require_relative '../../lib/file_replicator/joiner_cmd_parse'

class JoinerCommandLineParserTest < Minitest::Test

  def setup
    ARGV.clear
    @parser = FileReplicator::JoinerCmdParse.new
  end

  def test_first_file_mandatory
    assert_raises(MissingArgumentException) {
      @parser.send :validate_first_file, options_by_params([])
    }
  end

  def test_first_file_exists
    File.stub :exist?, false do
      assert_raises(ArgumentError) {
        @parser.send :validate_first_file, options_by_params(%w(-f /somefile))
      }
    end
  end

  def test_last_file_mandatory
    assert_raises(MissingArgumentException) {
      @parser.send :validate_last_file, options_by_params([])
    }
  end

  def test_last_file_exists
    File.stub :exist?, false do
      assert_raises(ArgumentError) {
        @parser.send :validate_last_file, options_by_params(%w(-l /somefile))
      }
    end
  end

  def test_output_path_is_mandatory
    assert_raises(MissingArgumentException) {
      @parser.send :validate_directory, options_by_params([])
    }
  end

  private

  def options_by_params(params)
    ARGV.concat params
    @parser.send :parse_argv
  end

end