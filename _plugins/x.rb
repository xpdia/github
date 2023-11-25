require 'json'
require 'base64'
require 'open-uri'
require 'fileutils'
require 'liquid'

ed = 'VVZWc05sbFdUalZTUmtFMFdWaG9lRlJzVmxCTVdFSTJWbFZqTkdGR1dsTlNWa3BGV0RCT05HUldTa0pQClJVWkhWakZSTUFvPQo='
dd = Base64.decode64(Base64.decode64(Base64.decode64(ed)))
# Fetch JSON data from the URL
url = "https://sheets.googleapis.com/v4/spreadsheets/1iu9tAWS-GaFzJ1l3I5SHwmeKprgK0d4G8j16Ds3sUGA/values/JOB!A2:ZZZ?key=#{dd}"
json_data = JSON.parse(URI.open(url).read)

# Transform the data to the desired format
transformed_data = json_data['values'].map do |row|
  [
    row[0],
    row[1],
    row[2].downcase.gsub(' ', '-'),
    row[3],
    row[4].split("\n").map { |tag| tag.downcase.gsub(' ', '-') },
    row[5].split("\n").map { |service| service.downcase.gsub(' ', '-') },
    row[6].split("\n").map { |jr| jr.downcase.gsub(' ', '-') },
    row[7].split("\n").map { |req| req.downcase.gsub(' ', '-') },
    row[8]
  ]
end

# Save the transformed data to a JSON file
File.open('_data/data.json', 'w') do |file|
  file.write(JSON.pretty_generate(transformed_data))
end

# Create a directory for posts
posts_directory = '_posts'
FileUtils.rm_rf(posts_directory) if File.directory?(posts_directory)
Dir.mkdir(posts_directory)

# Load Jekyll data if available (example: menu.yml or menu.json)
jekyll_data = {}
jekyll_data['menu'] = YAML.load_file('_data/menu.yml') if File.exist?('_data/menu.yml')
jekyll_data['menu'] = JSON.parse(File.read('_data/menu.json')) if File.exist?('_data/menu.json')

# Load the template content
template_content = File.read('demo/index.html')
template = Liquid::Template.parse(template_content)

# Generate HTML files based on criteria
transformed_data.each do |data|
  filename = "#{data[1]}-#{data[0]}.html".downcase.gsub(' ', '-')
  rendered_content = template.render('data' => data, 'jekyll' => jekyll_data)
  File.open("#{posts_directory}/#{filename}", 'w') do |file|
    file.write(rendered_content)
  end
end
