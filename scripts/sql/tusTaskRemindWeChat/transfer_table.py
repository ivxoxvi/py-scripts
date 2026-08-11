import sys
from datetime import datetime
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent.parent))
from util.rw_file import rfile, wfile


def generate_sql(table_name, mappings, defaults, table):
    insert_sql_list = []
    for row in table:
        columns, values = [], []
        for field, map_func in mappings.items():
            columns.append(field)
            values.append(convert(map_func(row)))
        for field, default_value in defaults.items():
            if field in columns:
                continue
            columns.append(field)
            values.append(convert(default_value))
        column_part = ",".join(columns)
        value_part = ",".join(values)
        sql = f"INSERT INTO {table_name} ({column_part}) VALUES ({value_part})"
        insert_sql_list.append(sql)
    return insert_sql_list


def convert(value):
    if isinstance(value, str):
        value = "'" + value.replace("'", "''") + "'"
    elif isinstance(value, bool):
        value = "true" if value else "false"
    elif isinstance(value, (int, float)):
        value = str(value)
    elif value is None:
        value = "NULL"
    return value


def hours_to_cron(row):
    date_format = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(row["NextExecuteDate"], date_format)
    time_zones = [hour for hour in row["timeZone"].split(",") if hour != ""]

    cron = None
    cycle_time = int(row["cycleTime"])
    if cycle_time == 1:
        cron = f"{dt.minute} * * * *"
    elif cycle_time == 24:
        cron = f"{dt.minute} {dt.hour} * * *"
    elif cycle_time < 24:
        cron_hour = ",".join(
            [str((dt.hour + i * cycle_time) % 24) for i in range(24 // cycle_time)]
        )
        cron = f"{dt.minute} {cron_hour} * * *"
    else:
        raise ValueError(f"Unknown cycleTime: {cycle_time} type: {type(cycle_time)}")

    if time_zones is None or len(time_zones) == 0:
        return cron

    cron_list = cron.split(" ")
    if cron_list[1] == "*":
        hour_part = time_zones
    else:
        hour_part = cron_list[1].split(",")

    cron_list[1] = ",".join(hour.strip() for hour in hour_part if hour in time_zones)
    cron = " ".join(cron_list)
    if len(cron.split(" ")) != 5:
        raise ValueError(f"Invalid cron format: {cron}")
    return cron


def bulid_template(row):
    format = int(row["format"])
    if format == 1:
        return "(SFP)异常订单<br>数量：{amount},<br>订单号：<br>{splicingTableStr}"
    elif format == 2:
        return "WOS Log Warning：{amount},<br>{splicingTableStr}"
    elif format == 3:
        subject = row["subject"]
        return f"{subject}<br>{{splicingTableStr}}"
    else:
        subject = row["subject"]
        return f"{subject}" + "<br>{splicingTableStr}"


mappings = {
    "monitor_table_sql": lambda row: row["tsql"],
    "monitor_subject": lambda row: row["subject"],
    "monitor_to": lambda row: row["tobox"].replace("|", ","),
    "cron": hours_to_cron,
    "monitor_text_template": bulid_template,
    "status": lambda row: False if int(row["yxbz"]) == 0 else True,
    "send_type": lambda row: "wechat",
    "monitor_serve_name": lambda row: (
        "internal_monitor" if row["agentid"] == "1000012" else "external_monitor"
    ),
    "data_source": lambda row: "sqlserver",
    "execute_mode": lambda row: "cron",
}


from_table = rfile(r"tustaskremindsByWeChat.csv", typ="csv")
sql_list = generate_sql("sys_monitor_config", mappings, {}, from_table)
wfile("result.sql", sql_list, typ="list")

print("from_table:", len(from_table))
print("sql_list:", len(sql_list))

a = rfile(r"result.sql", typ="str")
print(a.count("INSERT"))
