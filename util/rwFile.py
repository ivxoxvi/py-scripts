import json
import inspect
import csv
from pathlib import Path

def rfile(path, *, type = 'str'):
    if not Path(path).is_absolute():
        caller_file = inspect.stack()[1].filename
        path = Path(caller_file).parent / path

    with open(path, 'r', encoding='utf-8') as file:
        if type == 'str':
            return file.read()
        if type == 'list':
            return file.readlines()
        if type == 'json':
            return json.load(file)
        if type == 'csv':
            return list(csv.DictReader(file))

def wfile(path, data, *, type = 'str'):
    if not Path(path).is_absolute():
        caller_file = inspect.stack()[1].filename
        path = Path(caller_file).parent / path

    with open(path, 'w', encoding='utf-8') as file:
        if type == 'str':
            file.write(str(data))
        if type == 'list':
            for item in data:
                file.write(item + '\n')
        if type == 'json':
            json.dump(data, file, ensure_ascii=False, indent=4)

    