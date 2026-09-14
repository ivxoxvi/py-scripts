import json


def read_tk_and_trans_and_item(file_path):
    result_list = []
    try:
        with open(file_path, "r") as file:
            lines = file.readlines()
        non_empty_lines = [line.strip() for line in lines if line.strip()]

        if len(non_empty_lines) % 3 != 0:
            raise ValueError("文件内容不符合预期格式，每三行应包含一个完整的数据结构。")

        for i in range(0, len(non_empty_lines), 3):
            trans_id = non_empty_lines[i]
            item_id = non_empty_lines[i + 1]
            ssa_tracking_number = non_empty_lines[i + 2]

            data_structure = {
                "TRANS_ID": trans_id,
                "ITEM_ID": item_id,
                "SSA_TRACKING_NUMBER": ssa_tracking_number,
            }
            result_list.append(data_structure)
        return result_list
    except FileNotFoundError:
        print(f"文件 {file_path} 未找到。")
        return []
    except Exception as e:
        print(f"发生错误：{e}")
        return []


def read_json(file_path):
    try:
        with open(file_path, "r") as file:
            data = json.load(file)
            return data
    except FileNotFoundError:
        print(f"文件 {file_path} 未找到。")
        return []
    except json.JSONDecodeError:
        print("文件内容不是有效的JSON格式。")
        return []
    except Exception as e:
        print(f"发生错误：{e}")
        return []


# 更新 tblYzcOrders 的 ebay_item_id 和 ebay_transaction_id
def construct_sql_update_yzc(tk_to_trans_and_item, on_to_tk):
    sql_statements = []
    for item in tk_to_trans_and_item:
        trans_id = item["TRANS_ID"]
        item_id = item["ITEM_ID"]
        ssa_tracking_number = item["SSA_TRACKING_NUMBER"]

        paypal_tx_id = None
        for entry in on_to_tk:
            if entry["tracking_number"] == ssa_tracking_number:
                paypal_tx_id = entry["PayPalTxID"]
                break

        if paypal_tx_id:
            sql = f"UPDATE tblYzcOrders SET ebay_item_id = '{item_id}', ebay_transaction_id = '{trans_id}' WHERE OrderID = '{paypal_tx_id}';"
            sql_statements.append(sql)
        else:
            print(f"未找到tracking_number {ssa_tracking_number} 对应的PayPalTxID。")
    return sql_statements


# 回滚 tblOrders 的 createDate 为原来的日期
def construct_sql_rollback_tblOrders_date(old_create_date):
    sql_statements = []
    for item in old_create_date:
        paypal_tx_id = item.get("PayPalTxID")
        create_date = item.get("createDate")
        if paypal_tx_id and create_date:
            sql = f"UPDATE tblOrders SET createDate = '{create_date}' WHERE StoreID = 888 AND PayPalTxID = '{paypal_tx_id}';"
            sql_statements.append(sql)
        else:
            print(f"数据中缺少必要的字段：{item}")
    return sql_statements


# 更新 tblOrders 的 createDate 为指定日期
def construct_sql_update_tblOrders_date(old_create_date, date):
    sql_statements = []
    for item in old_create_date:
        paypal_tx_id = item.get("PayPalTxID")
        sql = f"UPDATE tblOrders SET createDate = '{date}' WHERE StoreID = 888 AND PayPalTxID = '{paypal_tx_id}';"
        sql_statements.append(sql)
    return sql_statements


# 插入 tbl_ebay_delivery_auth
def construct_sql_insert_ebay_auth(tk_and_trans_and_item, on_and_tk, out_bound_date):
    sql_statements = []
    for item in on_and_tk:
        paypal_tx_id = item.get("PayPalTxID")
        tracking_number = item.get("tracking_number")

        item_id = None
        trans_id = None
        for entry in tk_and_trans_and_item:
            if entry["SSA_TRACKING_NUMBER"] == tracking_number:
                item_id = entry["ITEM_ID"]
                trans_id = entry["TRANS_ID"]

        out_bound_data = None
        for entry in out_bound_date:
            if entry["PayPalTxID"] == paypal_tx_id:
                out_bound_data = entry.get("order_create_date")
                break

        sql = f"""INSERT INTO tbl_ebay_delivery_auth (sales_order_number, shipmentid, ebayItemID, ebayTransactionID,
                                    parcelID,
                                    ebayOrderID, ebayLineItemID, warehouse, packageWeight,
                                    packageLength, packageHeight, packageWidth, itemWeight,
                                    itemLength, itemHeight,
                                    itemWidth, lastMileCarrier, lastMileProduct,
                                    lastMileTrackingNum, skuQuantity, outboundID,
                                    outboundOrderTime, outboundOrderStatus,
                                    outboundTime, lastMileShippingFee, currency, whVendor,
                                    whVendorAppID, ext2, data_type, push_ebay, memo,
                                    create_date_time, modified_date_time,
                                    countryCode, skuNo, skuInvQty, skuProdName, itemCode)
VALUES (N'{paypal_tx_id}', null, {item_id}, {trans_id}, N'to be confirmed', null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        N'to be confirmed', N'{out_bound_data}', N'to be confirmed', null, null,
        null, N'to be confirmed', N'to be confirmed', null, N'to be confirmed', N'to be confirmed',
        null, getdate(), getdate(), null, null, null, null, null);"""
        sql_statements.append(sql)
    return sql_statements


# 读取数据
# trackNumber 和 trans_id 和 item_id 的对应关系
tk_and_trans_and_item = read_tk_and_trans_and_item(".\mail.txt")
# 订单号 和 tracking_number 的对应关系
on_and_tk = read_json(".\on_and_tk.json")
# 订单的原始创建时间
old_create_date = read_json(".\old_create_date.json")
# 订单的 out_bound_date
out_bound_date = read_json(".\on_to_out_bound_date.json")

print(f"读取 tk_and_trans_and_item 数据 {len(tk_and_trans_and_item)} 条:\n")
for item in tk_and_trans_and_item:
    print(item)

print(f"\n读取 on_and_tk 数据 {len(on_and_tk)} 条:\n")
for item in on_and_tk:
    print(item)
print("\n读取数据完毕\n")

# 构造SQL语句
update_yzc_sql = construct_sql_update_yzc(tk_and_trans_and_item, on_and_tk)
update_tblOrders_date_sql = construct_sql_update_tblOrders_date(
    old_create_date, "2025-06-02 22:40:11.340"
)
insert_ebay_auth_sql = construct_sql_insert_ebay_auth(
    tk_and_trans_and_item, on_and_tk, out_bound_date
)
rollback_tblOrders_date_sql = construct_sql_rollback_tblOrders_date(old_create_date)

# 打印SQL语句
print(
    f"\n修改 tblYzcOrders, 赋值 ebay_item_id 和 ebay_transaction_id 的 SQL({len(update_yzc_sql)}):\n"
)
for sql in update_yzc_sql:
    print(sql)

print(
    f"\n修改 tblOrders 的 createDate 为 30 天内的 SQL({len(update_tblOrders_date_sql)}):\n"
)
for sql in update_tblOrders_date_sql:
    print(sql)

print(f"\n插入 tbl_ebay_delivery_auth 的 SQL({len(insert_ebay_auth_sql)}):\n")
for sql in insert_ebay_auth_sql:
    print(sql)

print(f"\n还原 tblOrders 的 createDate 的 SQL({len(rollback_tblOrders_date_sql)}):\n")
for sql in rollback_tblOrders_date_sql:
    print(sql)
