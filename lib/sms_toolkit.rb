# coding: utf-8

require 'sms_toolkit/rails/engine'

# Mixins
module SmsToolkit
  
  # Main toolkit class
  class PhoneNumbers

    # Normalizes the US phone number.
    # - Converts the number in the format "+1nnnnnnnnnn" or "001nnnnnnnnnn" to 10-digits.
    # - Leaves short-codes intact (e.g. "nnnnnn")
    def self.normalize(number)
      return number if number.blank?
      
      # Cleanup
      number = number.strip
      number = (number[0, 1] == '+' ? '+' : '') + number.gsub(/[^0-9]/, '')      
      
      number.gsub(/^\+?1?(\d{10})$/, '\1').gsub(/^001?(\d+)$/, '\1')
    end

    # Formats the 10-digit number or the short-code as the US number.
    def self.format(number)
      return number if number.blank?
      
      if /^\s*\+?[\d\-\s\(\)]+\s*$/ =~ number
        number = normalize(number)
        
        if /^\d{10}$/ =~ number
          format_10_digit_number(number)
        elsif /^\d{1,9}$/ =~ number
          format_short_code(number)
        else
          number
        end
      else
        number
      end
    end

    private

    # Formats 10-digit number
    def self.format_10_digit_number(number)
      "(#{number[0, 3]}) #{number[3, 3]}-#{number[6, 4]}"
    end

    # Formats short-code
    def self.format_short_code(number)
      number
    end

  end

  class Message
    attr_accessor :text

    def initialize(text)
      self.text = text
    end

    def to_ascii
      ascii_text = self.text.dup

      ascii_text.gsub!(/[’′ʻ´`‘’]/, "'")
      ascii_text.gsub!(/[“”‹›«»]/, '"')
      ascii_text.gsub!(/[‐−‒–—―]/, '-')
      ascii_text.gsub!(/[…⋯]/, "...")
      ascii_text.gsub!(/[◦‣∙◘◙]/, '*')
      ascii_text.gsub!(/[º°]/, 'o')
      ascii_text.gsub!(/[\u3133\u200b\u00a0\u2028\u{1f44d}\u{1f383}\u{1f44f}\u{1f483}]/, '')
      ascii_text.gsub!(/[\u{1f600}-\u{1f64f}]/, '') # smiles filtering out
      ascii_text.gsub!(/\u{189}/, '1/2')
      ascii_text.gsub!(/\u{188}/, '1/4')
      ascii_text.gsub!(/\u{190}/, '3/4')
      ascii_text.gsub!(/\u8531/, '1/3')
      ascii_text.gsub!(/\u8532/, '2/3')
      ascii_text.tr!("ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
                     "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")
      ascii_text.gsub!(/\&/, '')
      ascii_text.gsub!(/\P{ASCII}/, '')

      ascii_text
    end

    def to_ascii_with_diff
      ascii = to_ascii

      diff = self.text.dup.split('') - ascii.split('')

      [ascii, diff.uniq]
    end
  end
  
  # Helper mix-in
  module HelperMixin
  
    # Returns the formatted phone number
    def formatted_phone_number(number)
      PhoneNumbers.format(number)
    end

  end

  # sms text validation
  class Validations

    @@standard_chars = %w{@ £ $ ¥ è é ù ì ò Ç Ø ø Å å Δ _ Φ Γ Λ Ω Π Ψ Σ Θ Ξ Æ æ ß É ! " # ¤ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? ¡ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z Ä Ö Ñ Ü § ¿ a b c d e f g h i j k l m n o p q r s t u v w x y z ä ö ñ ü à}
    @@extended_chars = [ '^', '{', '}', '\\', '[', '~', ']', '|', '€' ]
    @@special_chars = ["\n", "\r", " "]
    @@valid_chars    = @@standard_chars + @@extended_chars + @@special_chars

    def self.validate_sms(model, *attributes)
      error_message = 'contains invalid characters'
      attributes.each do |attribute|
        model.errors.add(attribute, error_message) unless SmsToolkit::Validations.valid_sms?(model.send(attribute))
      end
    end

    def self.valid_sms?(text)
      return true if text.blank?
      text.each_char do |c|
        return false unless @@valid_chars.include?(c)
      end
      true
    end
  end
end

ActionView::Base.send :include, SmsToolkit::HelperMixin
