import pandas as pd
import sys
from pathlib import Path
from datetime import datetime

sys.path.append(str(Path(__file__).parent.parent.parent))
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
    cycle_time = int(row["cycleTime"])
    if cycle_time == 1:
        cron = f"{dt.minute} * * * *"
    elif cycle_time == 24:
        cron = f"{dt.minute} {dt.hour} * * *"
    elif cycle_time == 8:
        cron_hour = ",".join([str((dt.hour + i * cycle_time) % 24) for i in range(3)])
        cron = f"{dt.minute} {cron_hour} * * *"
    elif cycle_time == 6:
        cron_hour = ",".join([str((dt.hour + i * cycle_time) % 24) for i in range(4)])
        cron = f"{dt.minute} {cron_hour} * * *"
    else:
        raise ValueError(f"Unknown cycleTime: {cycle_time} type: {type(cycle_time)}")
    return cron


def bulid_template(row):
    charge = row["inCharge"]
    need_deal = "是" if row["isNeedDeal"] == "true" else "否"
    need_reply = "是" if row["isNeedReply"] == "true" else "否"
    template = f"""<table border='1' cellpadding='1' cellspacing='0' align='center'>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size='2' style='text-align: center;'>{charge}</font>
        </td>
        <td>
            <font size='2' style='text-align: center;'>监控</font>
        </td>
        <td>
            <font size='2' style='text-align: center;'>{need_deal}</font>
        </td>
        <td>
            <font size='2' style='text-align: center;'>{need_reply}</font>
        </td>
    </tr>
</table><br /><br /><br />
{{splicingTableStr}}"""
    return template


mappings = {
    "monitor_table_sql": lambda row: row["tsql"],
    "monitor_subject": lambda row: row["subject"],
    "monitor_to": lambda row: row["tobox"],
    "monitor_cc": lambda row: row["ccbox"],
    "monitor_table_field": concat_fields,
    "cron": datetime_to_cron,
    "monitor_text_template": bulid_template,
    "send_type": lambda row: "email",
}


from_table = rfile(r"tusTaskReminds.csv", type="csv")
defaults = {"monitor_text_template": ""}
sql_list = generate_sql("sys_monitor_config", mappings, defaults, from_table)
wfile("result.sql", sql_list, type="list")

print("from_table:", len(from_table))
print("sql_list:", len(sql_list))
