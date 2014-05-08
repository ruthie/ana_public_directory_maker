require "csv"
require "erb"
require_relative "./state_names"

input_filename=ARGV[0]
output_filename=ARGV[1]

puts "Reading from #{input_filename}"
puts "Will write to #{output_filename}"

def email_redact(email)
  unless email
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

states = {}
canada = []
other = []

CSV.foreach("/home/ruthie/Desktop/ANA/players-4-30-14.csv") do |parts|
  #opt in for directory
  if !["yes", "Y", "y", "on"].include?(parts[14])
    next
  end

  player = {}

  #list nyckelharpa.org email if it exists, otherwise other email
  state = parts[9]
  player['email'] = email_redact(parts[1]) || email_redact(parts[0])
  player['first_name'] = parts[4].strip
  player['last_name'] = parts[5].strip

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

template_filename="/home/ruthie/Desktop/ANA/directory.html.erb"
template = ERB.new(File.read(template_filename))

output_file = File.open(output_filename, 'w')
output_file.write(template.result)
