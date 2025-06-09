import json
import inspect
from pathlib import Path

def readFile(path, *, type = 'str'):
    real_path = None
    if not Path(path).is_absolute():
        caller_file = inspect.stack()[1].filename
        real_path = Path(caller_file).parent / path
    else:
        real_path = path

    with open(real_path, 'r') as file:
        if type == 'str':
            return file.read()
        if type == 'list':
            return file.readlines()
        if type == 'json':
            return json.load(file)