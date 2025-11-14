# frozen_string_literal: true

require "pp"

module PolicyOcr
  def self.call(filename)
    entry = []
    File.foreach(filename).with_index do |line, i|
      entry = [] if (i % 4).zero?
      entry.push(line.chomp) if i % 4 < 3
      create_num_blocks(entry) if i % 4 == 3
    end
  end

  # ["    _  _     _  _  _  _  _ ",
  #  "  | _| _||_||_ |_   ||_||_|",
  #  "  ||_  _|  | _||_|  ||_| _|"]
  def self.create_num_blocks(entry)
    num_blocks = []
    entry.each do |row|
      row.chars.each_slice(3).with_index do |(*a), i|
        num_blocks[i] ||= {
          block: [],
          resolution: "?"
        }
        num_blocks[i][:block].push(a)
      end
    end
    puts num_blocks.map { |e| e.fetch(:resolution) }.join
    num_blocks
  end
end
