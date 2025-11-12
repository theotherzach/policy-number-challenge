#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/policy_ocr"

puts PolicyOcr.call(ARGV[0])
