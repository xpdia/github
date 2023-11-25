require 'yaml'
require 'base64'
require 'net/http'
ed = 'VVZWc05sbFdUalZTUmtFMFdWaG9lRlJzVmxCTVdFSTJWbFZqTkdGR1dsTlNWa3BGV0RCT05HUldTa0pQClJVWkhWakZSTUFvPQo='
dd = Base64.decode64(Base64.decode64(Base64.decode64(ed)))
def fetch_sheet_data(dd, spreadsheet_id, sheet_name)
  range = sheet_name

  url = URI.parse("https://sheets.googleapis.com/v4/spreadsheets/#{spreadsheet_id}/values/#{range}!B2:B?key=#{dd}")
  
  response = JSON.parse(Net::HTTP.get(url).to_s)

  if response['values']
    response['values']
  else
    puts "Error fetching data: #{response['error']['message']}" if response['error']
    nil
  end
end

# Read sheet configurations from sheets.yml
sheets_config = YAML.load_file('sheets.yml')

# Iterate over each sheet configuration
sheets_config.each do |config|
  # Fetch data and write it to a JSON file
  sheet_data = fetch_sheet_data(dd, config['spreadsheet_id'], 'main')
  File.write("_data/main.json", JSON.dump(sheet_data))
end
