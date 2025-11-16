# frozen_string_literal: true

require_relative "policy_ocr/entry"

module PolicyOcr
  class MalformedFile < StandardError; end

  class << self
    def fail(message, error_class = MalformedFile)
      raise error_class, message
    end

    def call(filename, output_io = $stdout)
      validate_filename(filename)

      entry = Array.new(3)

      File.foreach(filename).with_index do |line, index|
        handle_line(entry, line.chomp! || line, index, output_io)
      end

      finalize_entry(entry, output_io)
    end

    private

    def handle_line(entry, line_body, index, output_io)
      group_index = index % 4

      if group_index < 3
        validate_row(line_body, index)
        entry[group_index] = line_body
        nil
      else
        validate_separator(line_body, index)
        output_io.puts(Entry.call(entry))
        entry.fill(nil)
      end
    end

    def finalize_entry(entry, output_io)
      return if entry.compact.empty?
      fail("File ended without enough lines for a full entry (expected 3 data lines)") unless entry.all?

      output_io.puts(Entry.call(entry))
    end

    def validate_filename(filename)
      fail("No input file provided") if filename.nil? || filename.strip.empty?
    end

    def validate_row(line_body, index)
      if line_body.length != 27
        fail("Line #{index + 1}: expected 27 characters, got #{line_body.length}")
      elsif !line_body.match?(/\A[ _|]+\z/)
        fail("Line #{index + 1}: invalid characters; only space, '|' and '_' allowed")
      end
    end

    def validate_separator(line_body, index)
      return if line_body.empty? || line_body.match?(/\A *\z/)

      fail("Line #{index + 1}: expected a blank separator line")
    end
  end
end
