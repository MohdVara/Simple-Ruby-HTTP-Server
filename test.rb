require 'yaml'
database_config = YAML::load_file('config.yml')

HOST = database_config["server_config"]["host"]


puts HOST
