require "csv"
require "erb"
require_relative "./state_names"

input_filename=ARGV[0]
output_filename=ARGV[1]

puts "Reading from #{input_filename}"
puts "Will write to #{output_filename}"

def email_redact(email)
  unless email and email.include? "@"
    return nil
  end

  email.downcase.
    sub("hyperlink:", "").
    sub("mailto:", "").
    sub("@", "(at)").
    gsub(".", "(dot)")
    #TODO:  this doesn't deal gracefully with people with dots in their usernames
    #TODO:  make all emails downcase
end

def location(parts)
  state = parts[8]
  city = parts[7]
  return "#{city}, #{state}"
end

states = {}
canada = []
other = []

CSV.foreach(input_filename) do |parts|
  #opt in for directory
  if !["yes", "Y", "y", "on"].include?(parts[13])
    next
  elsif parts[2].to_i < 2014
    next
  end

  player = {}

  #list nyckelharpa.org email if it exists, otherwise other email
  state = parts[8]
  player['email'] = email_redact(parts[1]) || email_redact(parts[0]) || location(parts)

  player['first_name'] = parts[3].strip
  player['last_name'] = parts[4].strip

  if state != nil
    state.strip!

    state_name = $state_abbr[state]
    if state_name
      states[state_name] = [] unless states[state_name]
      states[state_name] << player     
    elsif province_name = $province_abbr[state]
      player['location'] = province_name
      canada << player
    else
      player['location'] = state
      other << player      
    end
  end
end

template_filename="directory.html.erb"
template = ERB.new(File.read(template_filename))

output_file = File.open(output_filename, 'w')
output_file.write(template.result)
