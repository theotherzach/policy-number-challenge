#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/policy_ocr"

begin
  input_filename  = ARGV[0]
  output_filename = ARGV[1]

  if output_filename
    File.open(output_filename, "w") do |file|
      PolicyOcr.call(input_filename, file)
    end
  else
    PolicyOcr.call(input_filename)
  end
rescue PolicyOcr::MalformedFile, Errno::ENOENT => e
  warn e.message
  exit 1
end
