# frozen_string_literal: true

module PolicyOcr
  def self.call(filename)
    rows = [[]]
    File.foreach(filename) do |line|
      if line.strip.empty?
        unless rows.last.empty?
          parse_row(rows.last)
          rows.push([])
        end
      else
        rows.last.push(line)
      end
    end
  end

  def self.parse_row(row)
    puts (row.first.size / 3).times.map { "?" }.join
  end
end
