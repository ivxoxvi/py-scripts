import pandas as pd
import sys
from pathlib import Path
from datetime import datetime
import json

sys.path.append(str(Path(__file__).parent.parent.parent))
from util.rw_file import rfile, wfile

data = rfile(r"data.json", typ="json")

for item in data:
    item["salesOrderNumber"] = "test-2025-17-07-00" + str(count)
    item["originalSalesOrderNumber"] = "test-2025-17-07-00" + str(count) + "-ori"
    count += 1
print(json.dumps(data))
