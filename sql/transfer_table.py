import pandas as pd
import sys
from pathlib import Path
from datetime import datetime

sys.path.append(str(Path(__file__).parent.parent))
from util.rwFile import rfile, wfile


def generate_sql(table_name, mappings, defaults, table):
    insert_sql_list = []
    for row in table:
        columns, values = [], []
        for field, map_func in mappings.items():
            columns.append(field)
            values.append(escape(map_func(row)))
        for field, default_value in defaults.items():
            if field in columns:
                continue
            columns.append(field)
            values.append(escape(default_value))
        column_part = ",".join(columns)
        value_part = ",".join(values)
        sql = f"INSERT INTO {table_name} ({column_part}) VALUES ({value_part})"
        insert_sql_list.append(sql)
    return insert_sql_list


def escape(value):
    if isinstance(value, str):
        value = "'" + value.replace("'", "''") + "'"
    elif value is None:
        value = "NULL"
    return value


def concat_fields(row):
    fields = [f"field{i}" for i in range(1, 41)]
    result = ",".join(
        row[field] for field in fields if row[field] is not None and row[field] != ""
    )
    return result


def datetime_to_cron(row):
    date_format = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(row["NextExecuteDate"], date_format)

    cron = None
    cycle_time = row["cycleTime"]
    if cycle_time == 1 or cycle_time == "1":
        cron = f"{dt.minute} * * * *"
    elif cycle_time == 24 or cycle_time == "24":
        cron = f"{dt.minute} {dt.hour} * * *"
    elif cycle_time == 8 or cycle_time == "8":
        cron = f"{dt.minute} 4,12,20 * * *"
    elif cycle_time == 6 or cycle_time == "6":
        cron = f"{dt.minute} 2,8,14,20 * * *"
    else:
        raise ValueError(f"Unknown cycleTime: {cycle_time} type: {type(cycle_time)}")
    return cron


mappings = {
    "monitor_table_sql": lambda row: row["tsql"],
    "monitor_subject": lambda row: row["subject"],
    "monitor_to": lambda row: row["tobox"],
    "monitor_cc": lambda row: row["ccbox"],
    "monitor_table_field": concat_fields,
    "cron": datetime_to_cron,
}


from_table = rfile(r"tusTaskReminds.csv", type="csv")
defaults = {"monitor_text_template": ""}
sql_list = generate_sql("sys_monitor_config_1", mappings, defaults, from_table)
wfile("result.sql", sql_list, type="list")

print("from_table:", len(from_table))
print("sql_list:", len(sql_list))
