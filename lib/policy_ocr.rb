# frozen_string_literal: true

module PolicyOcr
  def self.call(filename)
    rows = [[]]
    File.foreach(filename) do |line|
      if line.strip.empty?
        rows.push([]) unless rows.last.empty?
      else
        rows.last.push(line)
      end
    end
    rows.reject(&:empty?)
        .each { puts "?" }
  end
end
