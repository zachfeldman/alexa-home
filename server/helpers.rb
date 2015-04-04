require 'numbers_in_words'
require 'numbers_in_words/duck_punch'

def command_present?(command, term)
  command.scan(/#{term}/).length > 0
end