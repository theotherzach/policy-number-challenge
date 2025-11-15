# frozen_string_literal: true

module PolicyOcr
  module Checksum
    class << self
      # Expects a 9-character string of digits "0"–"9".
      # A policy number is valid if:
      #
      #   (d1 + 2*d2 + 3*d3 + ... + 9*d9) mod 11 == 0
      #
      # where d1 is the rightmost digit.
      def valid?(digits)
        checksum(digits).zero?
      end

      private

      def checksum(digits)
        sum = 0

        # Rightmost digit is position 1 (d1), so we iterate from right to left.
        digits.chars.reverse.each_with_index do |char, index|
          position = index + 1
          digit = char.to_i
          sum += digit * position
        end

        sum % 11
      end
    end
  end
end
