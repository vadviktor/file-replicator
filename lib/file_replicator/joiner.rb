require 'fileutils'

new_file_name = '/home/ikon/tmp/new_talk.mkv'
split_file_basename = '/home/ikon/tmp/talk.mkv'
read_buffer      = 256 * 1024

FileUtils.rm_f new_file_name
File.open new_file_name, 'ab' do |f|

  file_number = 0
  loop do
    file_number     += 1
    split_part_file = "#{split_file_basename}.#{file_number}"
    break unless File.exist? split_part_file

    puts "Reading split file no. #{file_number}"
    begin
      split_file = File.open split_part_file, 'rb'
      while (data = split_file.read(read_buffer))
        print '.'
        f.write data
      end
    rescue => e
      puts "EXCEPTION: #{e.message}"
      f.close
    ensure
      puts "\n" 'closing split file'
      split_file.close unless split_file.nil?
    end
  end

  puts 'file joined, closing'
end