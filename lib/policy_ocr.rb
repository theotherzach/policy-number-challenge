# frozen_string_literal: true

module PolicyOcr
  def self.call(filename)
    line_count = 0
    File.foreach(filename) do
      line_count += 1
    end

    "?" if line_count.positive?
  end
end
