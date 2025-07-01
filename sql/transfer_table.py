import pandas as pd
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
from util.rwFile import rfile, wfile


def generate_sql(rules, default_map, from_table):
    sql_list = []
    for row in from_table:
        columns = []
        values = []
        for field_to, field_from in rules.items():
            columns.append(field_to)
            values.append(escape(row[field_from]))
        for field_to, default_value in default_map.items():
            if field_to in columns:
                continue
            columns.append(field_to)
            values.append(escape(default_value))
        column_part = ",".join(columns)
        value_part = ",".join(values)
        sql = f"INSERT INTO sys_monitor_config ({column_part}) VALUES ({value_part})"
        sql_list.append(sql)
    return sql_list


def escape(value):
    if isinstance(value, str):
        value = "'" + value.replace("'", "''") + "'"
    elif value is None:
        value = "NULL"
    return value


rules = {
    "monitor_table_sql": "tsql",
    "monitor_subject": "subject",
    "monitor_config_code": "subject",
    "monitor_to": "tobox",
    "monitor_cc": "ccbox",
}

default_map = {"monitor_text_template": ""}

from_table = rfile(r"tusTaskReminds.csv", type="csv")

sql_list = generate_sql(rules, default_map, from_table)

wfile("result.sql", sql_list, type="list")


print("from_table:", len(from_table))
print("sql_list:", len(sql_list))