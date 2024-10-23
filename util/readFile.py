def read(filePath, *, type = str):
    with open(filePath, 'r') as file:
        if type == str:
            return file.read()
        if type == list:
            return file.readlines()