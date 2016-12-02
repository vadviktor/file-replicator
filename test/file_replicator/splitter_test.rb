require_relative '../test_helper'

require_relative '../../lib/file_replicator/splitter'

class SplitterTest < Minitest::Test

  def setup
    @splitter = FileReplicator::Splitter
  end

  def test_onu_pattern
    path     = '/opt/file.bin'
    pattern  = 'file.{onu}.bin.{Onu}'
    num      = 3
    elements = 20
    assert_equal 'file.03.bin.03',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_path:    path,
                     chunk_number:  num,
                     max_elements: elements
                 })
  end

  def test_num_pattern
    path     = '/opt/file.bin'
    pattern  = 'file.{Num}.bin.{num}'
    num      = 3
    assert_equal 'file.3.bin.3',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_path:    path,
                     chunk_number:  num
                 })
  end

  def test_onu_missing_max_elements
    path    = '/opt/file.bin'
    pattern = 'file.bin.{Onu}'
    num     = 3
    refute_equal '/opt/file.bin.3',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_path:   path,
                     file_number: num
                 })
  end

  def test_gcn_pattern
    pattern = '/opt/{gCn}.file-{gcn}.bin'
    num     = 7
    assert_equal '/opt/7.file-7.bin',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_number: num
                 })
  end

  def test_ord_pattern
    path    = '/home/test/file.x'
    pattern = '{oRd}/opt/{ord}/file.bin'
    assert_equal '/home/test/opt/home/test/file.bin',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_path: path
                 })


  end

  def test_orf_pattern
    path    = '/home/test/file.x'
    pattern = '/opt/{ORF}-dir/{orf}'
    assert_equal '/opt/file.x-dir/file.x',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_path: path
                 })


  end

  def test_ore_pattern
    path    = '/home/test/file.x'
    pattern = '/opt/z{ore}-x{oRe}'
    assert_equal '/opt/z.x-x.x',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_path: path
                 })


  end

  def test_orb_pattern
    path    = '/home/test/file.x'
    pattern = '/opt/{orb}/{Orb}'
    assert_equal '/opt/file/file',
                 @splitter.send(:pattern_to_path, pattern, {
                     file_path: path
                 })


  end

end