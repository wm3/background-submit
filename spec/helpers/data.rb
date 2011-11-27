def data_file(path)
  File.expand_path('../fixtures/' + path, File.dirname(__FILE__))
end

def read_file(path)
  open(data_file(path), &:read)
end

def read_yaml(path)
  YAML.load(read_file(path))
end
