# frozen_string_literal: true

module PolicyOcr
  module Checksum
    class << self
      # Validates a policy number using a weighted checksum algorithm.
      # A policy number is valid if:
      #
      #   (d1 + 2*d2 + 3*d3 + ... + 9*d9) mod 11 == 0
      #
      # where d1 is the rightmost digit.
      #
      # @param digits [String] 9-character string of digits "0"-"9"
      #   Example: "123456789", "000000000", "711111111"
      # @return [Boolean] true if checksum validates, false otherwise
      #   Example: valid?("711111111") => true
      #   Example: valid?("123456789") => false
      def valid?(digits)
        checksum(digits).zero?
      end

      private

      # Calculates the weighted checksum for a policy number.
      #
      # @param digits [String] 9-character string of digits
      #   Example: "123456789"
      # @return [Integer] checksum value mod 11 (0 means valid)
      #   Example: 0, 5, 10
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
