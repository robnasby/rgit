#! /usr/bin/ruby

require 'digest/sha1'

class PackFile

  def initialize(file_path)

    @pack_file = File.open(file_path)
    raise InvalidFormatError if !is_valid?

  end

  def parse_file_header

    @pack_file.seek(0)
    file_header = @pack_file.read(12)

    magic = file_header.slice(0..3)
    version = file_header.slice(4..7).unpack('L>')[0]
    object_count = file_header.slice(8..11).unpack('L>')[0]

    Struct::PackFileHeader.new(magic, version, object_count)

  end

  def calculate_contents_hash

    hash_calculator = Digest::SHA1.new

    @pack_file.seek(0)
    bytes_remaining = @pack_file.size - 20
    while bytes_remaining > 0
      bytes_to_read = [bytes_remaining, 1024].min
      bytes_remaining -= bytes_to_read
      hash_calculator.update(@pack_file.read(bytes_to_read))
    end    

    hash_calculator.hexdigest()

  end

  def is_valid?

    is_valid_file_hash? && is_valid_file_header?

  end

  def is_valid_file_hash?

    file_header = parse_file_header()
    file_header.magic == "PACK" && file_header.version == 2

  end

  def is_valid_file_header?

    calculate_contents_hash() == read_contents_hash()

  end

  def read_contents_hash

    @pack_file.seek(@pack_file.size - 20)
    @pack_file.read(20).bytes.map {|b| '%02x' % b }.join

  end

end

class InvalidFormatError < StandardError

end

Struct.new("PackFileHeader", :magic, :version, :object_count)


class PackFileTester

  def run(arguments)

    pack_file_path = arguments[0]

    begin
      pack_file = PackFile.new(pack_file_path)
    rescue InvalidFormatError
      puts "Invalid format detected in pack file '#{pack_file_path}'."
    end
  end

end

PackFileTester.new.run(ARGV)
