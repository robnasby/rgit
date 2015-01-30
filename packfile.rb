#! /usr/bin/ruby

class PackFile

  def initialize(file_path)

    @pack_file = File.open(file_path)

  end

end


class PackFileTester

  def run(arguments)

    pack_file_path = arguments[0]
    pack_file = PackFile.new(pack_file_path)

  end

end

PackFileTester.new.run(ARGV)
