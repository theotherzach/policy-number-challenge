#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/policy_ocr"

begin
  PolicyOcr.call(ARGV[0])
rescue PolicyOcr::MalformedFile, Errno::ENOENT => e
  warn e.message
  exit 1
end
