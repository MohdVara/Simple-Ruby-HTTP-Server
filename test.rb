require 'yaml'

CONTENT_TYPE = YAML::load_file("config/content_type.yml")
DATABASE = YAML::load_file("config/server.yml")

puts CONTENT_TYPE


puts DATABASE["web_root"]