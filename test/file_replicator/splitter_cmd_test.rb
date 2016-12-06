require_relative '../test_helper'

require_relative '../../lib/file_replicator/splitter_cmd_parse'

class SplitterCommandLineParserTest < Minitest::Test

  def setup
    ARGV.clear
    @parser = FileReplicator::SplitterCmdParse.new
  end

  def test_size_wont_allow_unknown_measures
    assert_raises(ArgumentError) {
      @parser.send :validate_size_format,
                   options_by_params(%w(-s 123z))
    }
  end

  def test_size_wont_allow_invalid_format
    assert_raises(ArgumentError) {
      @parser.send :validate_size_format,
                   options_by_params(%w(-s m123))
    }
  end

  def test_size_and_elements_are_not_used_together
    assert_raises(ConflictingArgumentsExceptions) {
      @parser.send :validate_conflicting_split_size,
                   options_by_params(%w(-s 123m -e 3))
    }
  end

  def test_size_is_accepting_human_readable_format
    assert_nil @parser.send :validate_size_format,
                            options_by_params(%w(-s 123m))
  end

  def test_minimal_size_wont_allow_unknown_measures
    assert_raises(ArgumentError) {
      @parser.send :validate_minimal_size,
                   options_by_params(%w(-m 123z))
    }
  end

  def test_minimal_size_wont_allow_invalid_format
    assert_raises(ArgumentError) {
      @parser.send :validate_minimal_size,
                   options_by_params(%w(-m m123))
    }
  end

  def test_minimal_size_is_accepting_human_readable_format
    assert_nil @parser.send :validate_minimal_size,
                            options_by_params(%w(-m 123m))
  end

  def test_checksum_algorithm_is_supported
    assert_nil @parser.send :validate_checksum,
                            options_by_params(%w(--checksum mD5))
  end

  def test_checksum_algoritym_is_not_supported
    assert_raises(ArgumentError) {
      @parser.send :validate_checksum,
                   options_by_params(%w(--checksum mD4))
    }
  end

  def test_unknown_split_size
    assert_raises(MissingArgumentException) {
      @parser.send :validate_unknown_split_size, options_by_params([])
    }
  end

  def test_files_are_mandatory
    assert_raises(MissingArgumentException) {
      @parser.send :validate_files, options_by_params([])
    }
  end

  def test_output_directory_is_mandatory
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