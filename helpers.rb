def c_present?(command, term)
  command.scan(/#{term}/).length > 0
end