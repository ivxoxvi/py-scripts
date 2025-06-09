import json
import inspect
from pathlib import Path

def readFile(path, *, type = 'str'):
    caller_file = inspect.stack()[1].filename
    real_path = Path(caller_file).parent / path
    
    with open(real_path, 'r') as file:
        if type == 'str':
            return file.read()
        if type == 'list':
            return file.readlines()
        if type == 'json':
            return json.load(file)