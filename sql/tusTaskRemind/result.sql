INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tse.DisplayName,
       case
           when tse.shipping_fee_type = ''drop_shipping_account_buy_fee'' then N''一件代发''
           when tse.shipping_fee_type in (''pick_up_account_buy_fee'', ''pick_up_buyer_upload_fee'') then N''上门取货''
           when tse.shipping_fee_type in (''buyer_pick_up_account_buy_fee'') then N''上门自提''
           else tse.shipping_fee_type end as ''订单类型'',
       tor.PayPalTxID,
       tos.OrderStatus,
       replace(replace(replace(replace(tbot.itemcode, ''-001'', ''''), '''''''', ''''), ''['', ''''), '']'', '''') as sku,
       twe.warehouseCode,
       tbot.UpdatedDate
from tblBackOrderTrail tbot WITH (nolock)
         inner join tblorders tor WITH (nolock) on tor.StoreID = tbot.StoreID and tor.OrderNumber = tbot.OrderNumber
         inner join tblOrderStatus tos WITH (nolock) on tor.OrderStatus = tos.OrderStatusID
         inner join tblstoreexts tse WITH (nolock) on tor.StoreID = tse.StoreID
         left join tbl_parcel tpl WITH (nolock) on tpl.shipment_id = tbot.shipmentid
         left join tblWarehouseExts twe WITH (nolock) on twe.warehouseId = tpl.warehouse_id
where tbot.BackOrderFlag = 8
  and tbot.UpdatedDate > GETDATE() - 1
order by tbot.UpdatedDate desc, twe.warehouseCode, PayPalTxID','每日盘点美国仓库BO数据','its@gigacloudtech.com,wuyating@gigacloudtech.com,uswhcoordinator@gigacloudtech.com','liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com','店铺,订单类型,销售订单号,订单状态,SKU,仓库,BO时间','10 22 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>陈开亮</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tsp.Description as description,
       tst.id          as tblSyncTaskId,
       tst.status      as status,
       tst.FileId      as fileId,
       tst.errMsg      as errMsg
  from tblSyncTask tst with(nolock)
 inner join tblSyncPermission tsp with(nolock)
    on tst.AuthKey = tsp.AuthKey
 where tsp.id = 8
   and tst.STATUS = 3
   and tst.CreateTime > getdate()-1','【WOS-监控】【监测】中间件接口同步失败','liuchao@gigacloudtech.com','xiafei@gigacloudtech.com,liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com','description,tblSyncTaskId,status,fileId,errMsg','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
                       tor.PayPalTxID,
                       tor.OrderDate,
                       tod.ItemCode,
                       twe.warehouseCode WarehouseCode
                   from tblOrders tor with(nolock)
                            inner join tblOrderDetails tod with(nolock) on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                            inner join tblstoreExts tse  with(nolock) on tor.StoreID = tse.StoreID
                            left join tblshipments tss with(nolock) on tss.shipmentId = tod.shipmentId
                            left JOIN tblWarehouseExts twe with(nolock) on twe.warehouseId = tss.AssignedTo
                   where 1=1
                     and tse.sales_platform in (''dajian_fbm'',''dajian_wayfair_fbm'')
                     and tor.OrderStatus not in (16,32)
                     and (tod.ItemStatus =16 or tss.Status = 8)
                     and tor.orderDate > getdate()-60
                   order by tor.OrderDate desc
                   ','【重要】大健云BO订单','csr_giga@gigacloudtech.com','liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com','PayPalTxID,OrderDate,ItemCode,WarehouseCode','0 21 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>石珊珊,閤飞</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select distinct ts.StoreName,
                tos.OrderDate,
                ts.StorePrefix + ''-'' + CONVERT(varchar(50), tos.orderNumber) as OrderNumber,
                tos.PAYPALTXID                                               as ''salesOrderNumber'',
                toss.OrderStatus
from tblorders tos with (nolock)
         INNER JOIN tblOrderDetails tod with (nolock) on tos.storeid = tod.storeid and tos.orderNumber = tod.orderNumber
         INNER JOIN tblShipments tss with (nolock) on tod.ShipmentID = tss.ShipmentID
         INNER JOIN tblstores ts with (nolock) on tos.storeId = ts.storeId
         INNER JOIN tblstoreExts tse with (nolock) on ts.storeId = tse.storeId
         INNER JOIN tblOrderStatus toss with (nolock) on toss.OrderStatusID = tos.orderstatus
where tss.Carrier = 7
  and tse.StoreID not in
      (222, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320,
       321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342,
       343, 344, 345, 346, 347, 348)
  and tse.sales_platform in (''amazon_fbm'')
  and convert(varchar(100), tss.ShipDate, 110) = convert(varchar(100), getdate(), 110)','【重要】-如下超大件订单请检查运单号是否上传到销售平台','dongqiuqun@gigacloudtech.com,gaoxianglan@gigacloudtech.com,suzhou_CSR@gigacloudtech.com','liuchao@gigacloudtech.com,xiafei@gigacloudtech.com,chenkailiang@gigacloudtech.com','StoreName,OrderDate,OrderNumber,SalesOrderNumber,OrderStatus','0 21 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>董求群</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
                                                                                tos.orderDate
                                                                                 ,ts.StorePrefix+''-''+CONVERT(VARCHAR(50),tos.orderNumber) as OrderNumber
                                                                                 ,tos.PAYPALTXID  as OrderId
                                                                                 ,tls.orderstatus
                                                                            from  tblorders tos with(nolock)
                                                                                      INNER JOIN tblStores  ts with(nolock) on ts.storeID = tos.storeId
                                                                                      INNER JOIN tblOrderDetails tod with(nolock) on tod.storeID = tos.storeId and tos.orderNumber = tod.OrderNumber
                                                                                       INNER JOIN tblstoreExts  tse with(nolock) on ts.storeID = tse.StoreID
                                                                                      INNER JOIN tblOrderStatus tls  with(nolock)  on tos.orderstatus = tls.OrderStatusID
                                                                            where 1=1
                                                                              and tse.sales_platform in (''dajian_wayfair_fbm'', ''dajian_fbm'')
                                                                              and tos.ORDERSTATUS in (1,4)
                                                                            order by  tos.storeID','【WOS-监控】大健云 New Order And OnHold 订单','csr_giga@gigacloudtech.com','chenkailiang@gigacloudtech.com,liuchao@gigacloudtech.com,chenhuizhu@gigacloudtech.com','OrderDate,OrderNumber,OrderID,Orderstatus','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>石珊珊,刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tse.OrdersFrom,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and DATEPART(hour, getdate()) in (1, 23)
  and tbo.orderstatus not in (4, 16, 32)
  and tse.OrdersFrom = ''B2B''
group by tse.OrdersFrom, tbll.sales_order_number, tbll.carrier_id, tbll.message, toss.OrderStatus
union
select tse.OrdersFrom,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       tuh.WORKNAME                                AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join dbo.tuslogheader tuh with (nolock)
                    on tul.hisId = tuh.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus = 4
         inner join dbo.tblOrderDetails tod with (nolock)
                    on tbo.OrderNumber = tod.OrderNumber
                        and tbo.StoreID = tod.StoreID
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
                        and tse.OrdersFrom = ''B2B''
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
where tul.worktype in (137)
  and tul.workstatus = 1
  and tul.HISLINEID > 455348556
  and DATEPART(hour, getdate()) in (1, 23)
group by tse.OrdersFrom, tul.orderId, tul.errmessage, tuh.WORKNAME, toss.OrderStatus
union
select tse.OrdersFrom,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID and tse.OrdersFrom = ''B2B''
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tul.HISLINEID > 455348556
  and DATEPART(hour, getdate()) in (1, 23)
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
  and isnull(tbs.isInvoicePrinted, 0) <> 1
group by tse.OrdersFrom, tul.orderId, tul.errmessage, toss.OrderStatus','【B2B-监控】【重要】FedEx、UPS、Amazon Buy Label 失败','pingtaikefu@gigacloudtech.com','chenkailiang@gigacloudtech.com,liuchao@gigacloudtech.com,uswhcoordinator@gigacloudtech.com','From,OrderId,DealTime,WorkName,Info,OrderStatus','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>B2B客服</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select business_type,
       isnull(t.carrier, ''-'') as carrier,
       CA2,
       CA3,
       CA4,
       CA5,
       CA6,
       CA7,
       CA8,
       CA9,
       CA10,
       CA11,
       CAL2,
       CAN1,
       CAN2,
       CAN3,
       NJ2,
       NJ3,
       NJ4,
       AT1,
       AT2,
       AT3,
       AT4,
       AT5,
       ATN1,
       TX1,
       CANADAH1,
       [All]
from (SELECT wsv.sort,
             wsv.business_type,
             wsv.Carrier,
             wsv.CA2,
             wsv.CA3,
             wsv.CA4,
             wsv.CA5,
             wsv.CA6,
             wsv.CA7,
             wsv.CA8,
             wsv.CA9,
             wsv.CA10,
             wsv.CA11,
             wsv.CAL2,
             wsv.CAN1,
             wsv.CAN2,
             wsv.CAN3,
             wsv.NJ2,
             wsv.NJ3,
             wsv.NJ4,
             wsv.AT1,
             wsv.AT2,
             wsv.AT3,
             wsv.AT4,
             wsv.AT5,
             wsv.ATN1,
             wsv.TX1,
             wsv.CANADAH1,
             wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9 + wsv.CA10
                 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 + wsv.NJ3 +
             wsv.NJ4 + wsv.AT1 + wsv.AT2 +
             wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1 as [All]
      FROM (select t.business_type,
                   case t.business_type
                       when ''b2bcloudwh'' then 0
                       when ''b2b'' then 1
                       when ''dajian'' then 2
                       when ''zy'' then 3
                       else 0 end as     sort,
                   t.carrier,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         t.Carrier,
                         t.business_type,
                         sum(t.qty) qty
                  from (select t.warehouseCode,
                               t.Qty,
                               t.carrier,
                               case
                                   when t.sales_platform = ''b2b_batch_cloud_fbm'' then ''b2bcloudwh''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong != ''giga_b2b_1p''
                                       then ''b2b''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong = ''giga_b2b_1p''
                                       then ''zy''
                                   when t.belong_to_sales = ''giga_b2b_inner_sales'' then ''zy''
                                   when t.belong_to_sales = ''giga_3pl_out_sales'' then ''dajian''
                                   else ''b2b'' end business_type
                        from (select t.warehouseCode,
                                     t.Qty,
                                     t.carrier,
                                     t.sales_platform,
                                     t.belong_to_sales,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = t.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong
                              from (select twe.warehouseCode,
                                           tpl.item_code + ''-001'' as itemcode,
                                           tpl.shipping_qty          Qty,
                                           tpl.carrier_name          carrier,
                                           tse.sales_platform,
                                           tse.belong_to_sales
                                    from tbl_parcel tpl with (nolock)
                                             inner join tblWarehouseExts twe with (nolock) on tpl.warehouse_id = twe.warehouseId
                                             inner join tblstoreExts tse with (nolock) on tse.storeid = tpl.store_id
                                    where tpl.carrier_name not in (''TRUCK'')
                                      and tpl.status not in (3)
                                      and twe.warehouseType = ''OSW''
                                      and tpl.create_date_time > getdate() - 2
                                      and CAST(tpl.create_date_time AS DATE) = CAST(GETDATE() AS DATE)
                                    union all
                                    select twe.warehouseCode,
                                           tpl.item_code + ''-001'' as itemcode,
                                           tpl.shipping_qty          Qty,
                                           tpl.carrier_name          carrier,
                                           tse.sales_platform,
                                           tse.belong_to_sales
                                    from tbl_parcel tpl with (nolock)
                                             inner join tblWarehouseExts twe with (nolock) on tpl.warehouse_id = twe.warehouseId
                                             inner join tblstoreExts tse with (nolock) on tse.storeid = tpl.store_id
                                    where tpl.carrier_name in (''TRUCK'')
                                      and tpl.status not in (3)
                                      and twe.warehouseType = ''OSW''
                                      and tpl.tracking_number is not null
                                      and ((tpl.scan_date_time is not null
                                        and tpl.scan_date_time > getdate() - 2
                                        and CAST(tpl.scan_date_time AS DATE) = CAST(GETDATE() AS DATE)
                                               )
                                        or
                                           (tpl.scan_date_time is null
                                               and exists(select 1
                                                          from tblTracking ttk with (nolock)
                                                          where ttk.ShipmentID = tpl.shipment_id
                                                            and CAST(ttk.enteredon AS DATE) = CAST(GETDATE() AS DATE)))
                                        )) t) t) t
                  group by t.warehouseCode, t.carrier, t.business_type) t PIVOT (SUM(t.qty) FOR WarehouseCode IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")
                     ) AS T) as wsv
      union all
      SELECT wsv.sort,
             wsv.business_type + ''_sum'',
             null                                                                 as carrier,
             sum(wsv.CA2),
             sum(wsv.CA3),
             sum(wsv.CA4),
             sum(wsv.CA5),
             sum(wsv.CA6),
             sum(wsv.CA7),
             sum(wsv.CA8),
             sum(wsv.CA9),
             sum(wsv.CA10),
             sum(wsv.CA11),
             sum(wsv.CAL2),
             sum(wsv.CAN1),
             sum(wsv.CAN2),
             sum(wsv.CAN3),
             sum(wsv.NJ2),
             sum(wsv.NJ3),
             sum(wsv.NJ4),
             sum(wsv.AT1),
             sum(wsv.AT2),
             sum(wsv.AT3),
             sum(wsv.AT4),
             sum(wsv.AT5),
             sum(wsv.ATN1),
             sum(wsv.TX1),
             sum(wsv.CANADAH1),
             sum(wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
                 wsv.NJ3 +
                 wsv.NJ4 + wsv.AT1 + wsv.AT2 +
                 wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1) as [All]
      FROM (select t.business_type,
                   case t.business_type
                       when ''b2bcloudwh'' then 0
                       when ''b2b'' then 1
                       when ''dajian'' then 2
                       when ''zy'' then 3
                       else 0 end as     sort,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         t.Carrier,
                         t.business_type,
                         sum(t.qty) qty
                  from (select t.warehouseCode,
                               t.Qty,
                               t.carrier,
                               case
                                   when t.sales_platform = ''b2b_batch_cloud_fbm'' then ''b2bcloudwh''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong != ''giga_b2b_1p''
                                       then ''b2b''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong = ''giga_b2b_1p''
                                       then ''zy''
                                   when t.belong_to_sales = ''giga_b2b_inner_sales'' then ''zy''
                                   when t.belong_to_sales = ''giga_3pl_out_sales'' then ''dajian''
                                   else ''b2b'' end business_type
                        from (select t.warehouseCode,
                                     t.Qty,
                                     t.carrier,
                                     t.sales_platform,
                                     t.belong_to_sales,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = t.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong
                              from (select twe.warehouseCode,
                                           tpl.item_code + ''-001'' as itemcode,
                                           tpl.shipping_qty          Qty,
                                           tpl.carrier_name          carrier,
                                           tse.sales_platform,
                                           tse.belong_to_sales
                                    from tbl_parcel tpl with (nolock)
                                             inner join tblWarehouseExts twe with (nolock) on tpl.warehouse_id = twe.warehouseId
                                             inner join tblstoreExts tse with (nolock) on tse.storeid = tpl.store_id
                                    where tpl.carrier_name not in (''TRUCK'')
                                      and tpl.status not in (3)
                                      and twe.warehouseType = ''OSW''
                                      and tpl.create_date_time > getdate() - 2
                                      and CAST(tpl.create_date_time AS DATE) = CAST(GETDATE() AS DATE)
                                    union all
                                    select twe.warehouseCode,
                                           tpl.item_code + ''-001'' as itemcode,
                                           tpl.shipping_qty          Qty,
                                           tpl.carrier_name          carrier,
                                           tse.sales_platform,
                                           tse.belong_to_sales
                                    from tbl_parcel tpl with (nolock)
                                             inner join tblWarehouseExts twe with (nolock) on tpl.warehouse_id = twe.warehouseId
                                             inner join tblstoreExts tse with (nolock) on tse.storeid = tpl.store_id
                                    where tpl.carrier_name in (''TRUCK'')
                                      and tpl.status not in (3)
                                      and twe.warehouseType = ''OSW''
                                      and tpl.tracking_number is not null
                                      and ((tpl.scan_date_time is not null
                                        and tpl.scan_date_time > getdate() - 2
                                        and CAST(tpl.scan_date_time AS DATE) = CAST(GETDATE() AS DATE)
                                               )
                                        or
                                           (tpl.scan_date_time is null
                                               and exists(select 1
                                                          from tblTracking ttk with (nolock)
                                                          where ttk.ShipmentID = tpl.shipment_id
                                                            and CAST(ttk.enteredon AS DATE) = CAST(GETDATE() AS DATE)))
                                        )) t) t) t
                  group by t.warehouseCode, t.carrier, t.business_type) t PIVOT (SUM(t.qty) FOR WarehouseCode IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")
                     ) AS T) wsv
      group by wsv.sort, wsv.business_type
      UNION ALL
      SELECT wsv.sort,
             wsv.storetype,
             null                                                               carrier,
             wsv.CA2,
             wsv.CA3,
             wsv.CA4,
             wsv.CA5,
             wsv.CA6,
             wsv.CA7,
             wsv.CA8,
             wsv.CA9,
             wsv.CA10,
             wsv.CA11,
             wsv.CAL2,
             wsv.CAN1,
             wsv.CAN2,
             wsv.CAN3,
             wsv.NJ2,
             wsv.NJ3,
             wsv.NJ4,
             wsv.AT1,
             wsv.AT2,
             wsv.AT3,
             wsv.AT4,
             wsv.AT5,
             wsv.ATN1,
             wsv.TX1,
             wsv.CANADAH1,
             wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
             wsv.NJ3 +
             wsv.NJ4 + wsv.AT1 + wsv.AT2 +
             wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1 as [All]
      FROM (select ''all''                 storetype,
                   4 as                  sort,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         null       carrier,
                         sum(t.qty) qty
                  from (select t.warehouseCode,
                               t.Carrier,
                               sum(t.qty) qty
                        from (select t.warehouseCode,
                                     t.Qty,
                                     t.carrier,
                                     case
                                         when t.sales_platform = ''b2b_batch_cloud_fbm'' then ''b2bcloudwh''
                                         when t.belong_to_sales = ''giga_b2b_out_sales'' and
                                              t.item_belong != ''giga_b2b_1p''
                                             then ''b2b''
                                         when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong = ''giga_b2b_1p''
                                             then ''zy''
                                         when t.belong_to_sales = ''giga_b2b_inner_sales'' then ''zy''
                                         when t.belong_to_sales = ''giga_3pl_out_sales'' then ''dajian''
                                         else ''b2b'' end business_type
                              from (select t.warehouseCode,
                                           t.itemcode,
                                           t.Qty,
                                           t.carrier,
                                           t.sales_platform,
                                           t.belong_to_sales,
                                           isnull((SELECT top 1 full_platform
                                                   from tbl_relation_item_inventory trii with (nolock)
                                                   where trii.item_code = t.itemcode
                                                   order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong
                                    from (select twe.warehouseCode,
                                                 tpl.item_code + ''-001'' as itemcode,
                                                 tpl.shipping_qty          Qty,
                                                 tpl.carrier_name          carrier,
                                                 tse.sales_platform,
                                                 tse.belong_to_sales
                                          from tbl_parcel tpl with (nolock)
                                                   inner join tblWarehouseExts twe with (nolock) on tpl.warehouse_id = twe.warehouseId
                                                   inner join tblstoreExts tse with (nolock) on tse.storeid = tpl.store_id
                                          where tpl.carrier_name not in (''TRUCK'')
                                            and tpl.status not in (3)
                                            and twe.warehouseType = ''OSW''
                                            and tpl.create_date_time > getdate() - 2
                                            and CAST(tpl.create_date_time AS DATE) = CAST(GETDATE() AS DATE)
                                          union all
                                          select twe.warehouseCode,
                                                 tpl.item_code + ''-001'' as itemcode,
                                                 tpl.shipping_qty          Qty,
                                                 tpl.carrier_name          carrier,
                                                 tse.sales_platform,
                                                 tse.belong_to_sales
                                          from tbl_parcel tpl with (nolock)
                                                   inner join tblWarehouseExts twe with (nolock) on tpl.warehouse_id = twe.warehouseId
                                                   inner join tblstoreExts tse with (nolock) on tse.storeid = tpl.store_id
                                          where tpl.carrier_name in (''TRUCK'')
                                            and tpl.status not in (3)
                                            and twe.warehouseType = ''OSW''
                                            and tpl.tracking_number is not null
                                            and (
                                              (tpl.scan_date_time is not null
                                                  and tpl.scan_date_time > getdate() - 2
                                                  and CAST(tpl.scan_date_time AS DATE) = CAST(GETDATE() AS DATE)
                                                  )
                                                  or
                                              (
                                                  tpl.scan_date_time is null
                                                      and exists(select 1
                                                                 from tblTracking ttk with (nolock)
                                                                 where ttk.ShipmentID = tpl.shipment_id
                                                                   and CAST(ttk.enteredon AS DATE) = CAST(GETDATE() AS DATE))
                                                  )
                                              )) t) t) t
                        group by t.warehouseCode, t.carrier, t.business_type) t
                  group by t.warehouseCode, t.carrier) t PIVOT (SUM(t.qty) FOR [WarehouseCode] IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1", "CANADAH1")) AS T) wsv) t
where t.business_type <> ''b2bcloudwh_sum''
order by t.sort, t.business_type','【WOS-监控】美国仓库已发单数日报','larry_wu@gigacloudtech.com,haoxinyan@gigacloudtech.com,wanxin@gigacloudtech.com,wangyan@gigacloudtech.com,mabin@gigacloudtech.com,xukunming@gigacloudtech.com,lunjia.li@gigacloudtech.com,wang.xin@gigacloudtech.com,stella.tian@gigacloudtech.com','mingdi.zhang@gigacloudtech.com,lei.yan@gigacloudtech.com,wenbo.dou@gigacloudtech.com,chris.xu@gigacloudtech.com,uswarehouse@gigacloudtech.com,shishanshan@gigacloudtech.com,uswhcoordinator@gigacloudtech.com,logistics@gigacloudtech.com,yuanwen@gigacloudtech.com,zhanghanlin@gigacloudtech.com,zhanghuiwen@gigacloudtech.com,xiafei@gigacloudtech.com,liuchao@gigacloudtech.com','业务类型,物流方式,CA2,CA3,CA4,CA5,CA6,CA7,CA8,CA9,CA10,CA11,CAL2,CAN1,CAN2,CAN3,NJ2,NJ3,NJ4,AT1,AT2,AT3,AT4,AT5,ATN1,TX1,CANADAH1,[ALL]','30 16 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select business_type,
       isnull(CarrierCode, '''') as Carrier,
       CA2,
       CA3,
       CA4,
       CA5,
       CA6,
       CA7,
       CA8,
       CA9,
       CA10,
       CA11,
       CAL2,
       CAN1,
       CAN2,
       CAN3,
       NJ2,
       NJ3,
       NJ4,
       AT1,
       AT2,
       AT3,
       AT4,
       AT5,
       ATN1,
       TX1,
       CANADAH1,
       [All]
from (SELECT wsv.sort,
             wsv.business_type,
             wsv.CarrierCode,
             wsv.CA2,
             wsv.CA3,
             wsv.CA4,
             wsv.CA5,
             wsv.CA6,
             wsv.CA7,
             wsv.CA8,
             wsv.CA9,
             wsv.CA10,
             wsv.CA11,
             wsv.CAL2,
             wsv.CAN1,
             wsv.CAN2,
             wsv.CAN3,
             wsv.NJ2,
             wsv.NJ3,
             wsv.NJ4,
             wsv.AT1,
             wsv.AT2,
             wsv.AT3,
             wsv.AT4,
             wsv.AT5,
             wsv.ATN1,
             wsv.TX1,
             wsv.CANADAH1,
             wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
             wsv.NJ3 +
             wsv.NJ4 + wsv.AT1 + wsv.AT2 +
             wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1 as [All]
      FROM (select t.business_type,
                   case t.business_type
                       when ''b2bcloudwh'' then 0
                       when ''b2b'' then 1
                       when ''dajian'' then 2
                       when ''zy'' then 3
                       else 0 end as     sort,
                   t.CarrierCode,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         t.CarrierCode,
                         t.business_type,
                         sum(t.qty) qty
                  from (select case
                                   when t.sales_platform = ''b2b_batch_cloud_fbm'' then ''b2bcloudwh''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong != ''giga_b2b_1p''
                                       then ''b2b''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong = ''giga_b2b_1p''
                                       then ''zy''
                                   when t.belong_to_sales = ''giga_b2b_inner_sales'' then ''zy''
                                   when t.belong_to_sales = ''giga_3pl_out_sales'' then ''dajian''
                                   else ''b2b'' end business_type,
                               t.carriercode,
                               t.warehousecode,
                               t.qty
                        from (select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier <> 7
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID in (226)
                                and not exists(select 1
                                               from tblCloudWarehouseLabel tcwl
                                               where tcwl.OrderId = tblo.PayPalTxID
                                                 and tcwl.WarehouseId = tbls.AssignedTo
                                                 and tcwl.PickingListDownloadTime is not null)
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID not in (226)
                                and not exists(select 1
                                               from tbl_extra_shipping_file tesf
                                               where tesf.shipment_id = tbls.ShipmentID
                                                 and tesf.is_valid = 1
                                                 and merge_date_time is not null)) t) t
                  group by t.warehouseCode, t.CarrierCode, t.business_type) t PIVOT (SUM(t.qty) FOR [WarehouseCode] IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")) AS T) wsv
      union all
      SELECT wsv.sort,
             wsv.business_type + ''_sum'',
             null                                                                           as CarrierCode,
             sum(wsv.CA2),
             sum(wsv.CA3),
             sum(wsv.CA4),
             sum(wsv.CA5),
             sum(wsv.CA6),
             sum(wsv.CA7),
             sum(wsv.CA8),
             sum(wsv.CA9),
             sum(wsv.CA10),
             sum(wsv.CA11),
             sum(wsv.CAL2),
             sum(wsv.CAN1),
             sum(wsv.CAN2),
             sum(wsv.CAN3),
             sum(wsv.NJ2),
             sum(wsv.NJ3),
             sum(wsv.NJ4),
             sum(wsv.AT1),
             sum(wsv.AT2),
             sum(wsv.AT3),
             sum(wsv.AT4),
             sum(wsv.AT5),
             sum(wsv.ATN1),
             sum(wsv.TX1),
             sum(wsv.CANADAH1),
             sum(wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
                 wsv.NJ3 +
                 wsv.NJ4 + wsv.AT1 +
                 wsv.AT2 + wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1) as [All]
      FROM (select t.business_type,
                   case t.business_type
                       when ''b2bcloudwh'' then 0
                       when ''b2b'' then 1
                       when ''dajian'' then 2
                       when ''zy'' then 3
                       else 0 end as     sort,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         t.CarrierCode,
                         t.business_type,
                         sum(t.qty) qty
                  from (select case
                                   when t.sales_platform = ''b2b_batch_cloud_fbm'' then ''b2bcloudwh''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong != ''giga_b2b_1p''
                                       then ''b2b''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong = ''giga_b2b_1p''
                                       then ''zy''
                                   when t.belong_to_sales = ''giga_b2b_inner_sales'' then ''zy''
                                   when t.belong_to_sales = ''giga_3pl_out_sales'' then ''dajian''
                                   else ''b2b'' end business_type,
                               t.carriercode,
                               t.warehousecode,
                               t.qty
                        from (select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier <> 7
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID in (226)
                                and not exists(select 1
                                               from tblCloudWarehouseLabel tcwl
                                               where tcwl.OrderId = tblo.PayPalTxID
                                                 and tcwl.WarehouseId = tbls.AssignedTo
                                                 and tcwl.PickingListDownloadTime is not null)
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID not in (226)
                                and not exists(select 1
                                               from tbl_extra_shipping_file tesf
                                               where tesf.shipment_id = tbls.ShipmentID
                                                 and tesf.is_valid = 1
                                                 and merge_date_time is not null)) t) t
                  group by t.warehouseCode, t.CarrierCode, t.business_type) t PIVOT (SUM(t.qty) FOR [WarehouseCode] IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")) AS T) wsv
      group by wsv.sort, wsv.business_type
      UNION ALL
      SELECT wsv.sort,
             wsv.business_type,
             null                                                               CarrierCode,
             wsv.CA2,
             wsv.CA3,
             wsv.CA4,
             wsv.CA5,
             wsv.CA6,
             wsv.CA7,
             wsv.CA8,
             wsv.CA9,
             wsv.CA10,
             wsv.CA11,
             wsv.CAL2,
             wsv.CAN1,
             wsv.CAN2,
             wsv.CAN3,
             wsv.NJ2,
             wsv.NJ3,
             wsv.NJ4,
             wsv.AT1,
             wsv.AT2,
             wsv.AT3,
             wsv.AT4,
             wsv.AT5,
             wsv.ATN1,
             wsv.TX1,
             wsv.CANADAH1,
             wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
             wsv.NJ3 +
             wsv.NJ4 + wsv.AT1 + wsv.AT2 +
             wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1 as [All]
      FROM (select ''all''                 business_type,
                   4    as               sort,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         sum(t.qty) qty
                  from (select
                            t.carriercode,
                            t.warehousecode,
                            t.qty
                        from (select
                                  tblc.carriercode,
                                  tbwe.warehousecode,
                                  tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier <> 7
                              union all
                              select
                                  tblc.carriercode,
                                  tbwe.warehousecode,
                                  tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID in (226)
                                and not exists(select 1
                                               from tblCloudWarehouseLabel tcwl
                                               where tcwl.OrderId = tblo.PayPalTxID
                                                 and tcwl.WarehouseId = tbls.AssignedTo
                                                 and tcwl.PickingListDownloadTime is not null)
                              union all
                              select
                                  tblc.carriercode,
                                  tbwe.warehousecode,
                                  tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID not in (226)
                                and not exists(select 1
                                               from tbl_extra_shipping_file tesf
                                               where tesf.shipment_id = tbls.ShipmentID
                                                 and tesf.is_valid = 1
                                                 and merge_date_time is not null)) t) t
                  group by t.warehouseCode, t.CarrierCode) t PIVOT (SUM(t.qty) FOR [WarehouseCode] IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")) AS T) wsv) t
where t.business_type <> ''b2bcloudwh_sum''
order by t.sort, t.business_type','【WOS-监控】【CA时间19点】美国仓库待发单统计','larry_wu@gigacloudtech.com,haoxinyan@gigacloudtech.com,wanxin@gigacloudtech.com,wangyan@gigacloudtech.com,mabin@gigacloudtech.com,xukunming@gigacloudtech.com,lunjia.li@gigacloudtech.com,wang.xin@gigacloudtech.com,stella.tian@gigacloudtech.com','mingdi.zhang@gigacloudtech.com,lei.yan@gigacloudtech.com,wenbo.dou@gigacloudtech.com,chris.xu@gigacloudtech.com,uswarehouse@gigacloudtech.com,shishanshan@gigacloudtech.com,uswhcoordinator@gigacloudtech.com,logistics@gigacloudtech.com,yuanwen@gigacloudtech.com,zhanghanlin@gigacloudtech.com,zhanghuiwen@gigacloudtech.com,xiafei@gigacloudtech.com,liuchao@gigacloudtech.com','业务类型,物流方式,CA2,CA3,CA4,CA5,CA6,CA7,CA8,CA9,CA10,CA11,CAL2,CAN1,CAN2,CAN3,NJ2,NJ3,NJ4,AT1,AT2,AT3,AT4,AT5,ATN1,TX1,CANADAH1,[ALL]','15 19 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select business_type,
       isnull(CarrierCode, '''') as Carrier,
       CA2,
       CA3,
       CA4,
       CA5,
       CA6,
       CA7,
       CA8,
       CA9,
       CA10,
       CA11,
       CAL2,
       CAN1,
       CAN2,
       CAN3,
       NJ2,
       NJ3,
       NJ4,
       AT1,
       AT2,
       AT3,
       AT4,
       AT5,
       ATN1,
       TX1,
       CANADAH1,
       [All]
from (SELECT wsv.sort,
             wsv.business_type,
             wsv.CarrierCode,
             wsv.CA2,
             wsv.CA3,
             wsv.CA4,
             wsv.CA5,
             wsv.CA6,
             wsv.CA7,
             wsv.CA8,
             wsv.CA9,
             wsv.CA10,
             wsv.CA11,
             wsv.CAL2,
             wsv.CAN1,
             wsv.CAN2,
             wsv.CAN3,
             wsv.NJ2,
             wsv.NJ3,
             wsv.NJ4,
             wsv.AT1,
             wsv.AT2,
             wsv.AT3,
             wsv.AT4,
             wsv.AT5,
             wsv.ATN1,
             wsv.TX1,
             wsv.CANADAH1,
             wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
             wsv.NJ3 +
             wsv.NJ4 + wsv.AT1 + wsv.AT2 +
             wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1 as [All]
      FROM (select t.business_type,
                   case t.business_type
                       when ''b2bcloudwh'' then 0
                       when ''b2b'' then 1
                       when ''dajian'' then 2
                       when ''zy'' then 3
                       else 0 end as     sort,
                   t.CarrierCode,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         t.CarrierCode,
                         t.business_type,
                         sum(t.qty) qty
                  from (select case
                                   when t.sales_platform = ''b2b_batch_cloud_fbm'' then ''b2bcloudwh''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong != ''giga_b2b_1p''
                                       then ''b2b''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong = ''giga_b2b_1p''
                                       then ''zy''
                                   when t.belong_to_sales = ''giga_b2b_inner_sales'' then ''zy''
                                   when t.belong_to_sales = ''giga_3pl_out_sales'' then ''dajian''
                                   else ''b2b'' end business_type,
                               t.carriercode,
                               t.warehousecode,
                               t.qty
                        from (select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier <> 7
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID in (226)
                                and not exists(select 1
                                               from tblCloudWarehouseLabel tcwl
                                               where tcwl.OrderId = tblo.PayPalTxID
                                                 and tcwl.WarehouseId = tbls.AssignedTo
                                                 and tcwl.PickingListDownloadTime is not null)
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID not in (226)
                                and not exists(select 1
                                               from tbl_extra_shipping_file tesf
                                               where tesf.shipment_id = tbls.ShipmentID
                                                 and tesf.is_valid = 1
                                                 and merge_date_time is not null)) t) t
                  group by t.warehouseCode, t.CarrierCode, t.business_type) t PIVOT (SUM(t.qty) FOR [WarehouseCode] IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")) AS T) wsv
      union all
      SELECT wsv.sort,
             wsv.business_type + ''_sum'',
             null                                                                           as CarrierCode,
             sum(wsv.CA2),
             sum(wsv.CA3),
             sum(wsv.CA4),
             sum(wsv.CA5),
             sum(wsv.CA6),
             sum(wsv.CA7),
             sum(wsv.CA8),
             sum(wsv.CA9),
             sum(wsv.CA10),
             sum(wsv.CA11),
             sum(wsv.CAL2),
             sum(wsv.CAN1),
             sum(wsv.CAN2),
             sum(wsv.CAN3),
             sum(wsv.NJ2),
             sum(wsv.NJ3),
             sum(wsv.NJ4),
             sum(wsv.AT1),
             sum(wsv.AT2),
             sum(wsv.AT3),
             sum(wsv.AT4),
             sum(wsv.AT5),
             sum(wsv.ATN1),
             sum(wsv.TX1),
             sum(wsv.CANADAH1),
             sum(wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
                 wsv.NJ3 +
                 wsv.NJ4 + wsv.AT1 +
                 wsv.AT2 + wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1) as [All]
      FROM (select t.business_type,
                   case t.business_type
                       when ''b2bcloudwh'' then 0
                       when ''b2b'' then 1
                       when ''dajian'' then 2
                       when ''zy'' then 3
                       else 0 end as     sort,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         t.CarrierCode,
                         t.business_type,
                         sum(t.qty) qty
                  from (select case
                                   when t.sales_platform = ''b2b_batch_cloud_fbm'' then ''b2bcloudwh''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong != ''giga_b2b_1p''
                                       then ''b2b''
                                   when t.belong_to_sales = ''giga_b2b_out_sales'' and t.item_belong = ''giga_b2b_1p''
                                       then ''zy''
                                   when t.belong_to_sales = ''giga_b2b_inner_sales'' then ''zy''
                                   when t.belong_to_sales = ''giga_3pl_out_sales'' then ''dajian''
                                   else ''b2b'' end business_type,
                               t.carriercode,
                               t.warehousecode,
                               t.qty
                        from (select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier <> 7
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID in (226)
                                and not exists(select 1
                                               from tblCloudWarehouseLabel tcwl
                                               where tcwl.OrderId = tblo.PayPalTxID
                                                 and tcwl.WarehouseId = tbls.AssignedTo
                                                 and tcwl.PickingListDownloadTime is not null)
                              union all
                              select tbse.sales_platform,
                                     tbse.belong_to_sales,
                                     tblc.carriercode,
                                     tbwe.warehousecode,
                                     isnull((SELECT top 1 full_platform
                                             from tbl_relation_item_inventory trii with (nolock)
                                             where trii.item_code = tbld.itemcode
                                             order by trii.modified_date_time DESC), ''giga_b2b_3p'') item_belong,
                                     tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID not in (226)
                                and not exists(select 1
                                               from tbl_extra_shipping_file tesf
                                               where tesf.shipment_id = tbls.ShipmentID
                                                 and tesf.is_valid = 1
                                                 and merge_date_time is not null)) t) t
                  group by t.warehouseCode, t.CarrierCode, t.business_type) t PIVOT (SUM(t.qty) FOR [WarehouseCode] IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")) AS T) wsv
      group by wsv.sort, wsv.business_type
      UNION ALL
      SELECT wsv.sort,
             wsv.business_type,
             null                                                               CarrierCode,
             wsv.CA2,
             wsv.CA3,
             wsv.CA4,
             wsv.CA5,
             wsv.CA6,
             wsv.CA7,
             wsv.CA8,
             wsv.CA9,
             wsv.CA10,
             wsv.CA11,
             wsv.CAL2,
             wsv.CAN1,
             wsv.CAN2,
             wsv.CAN3,
             wsv.NJ2,
             wsv.NJ3,
             wsv.NJ4,
             wsv.AT1,
             wsv.AT2,
             wsv.AT3,
             wsv.AT4,
             wsv.AT5,
             wsv.ATN1,
             wsv.TX1,
             wsv.CANADAH1,
             wsv.CA2 + wsv.CA3 + wsv.CA4 + wsv.CA5 + wsv.CA6 + wsv.CA7 + wsv.CA8 + wsv.CA9
                 + wsv.CA10 + wsv.CA11 + wsv.CAL2 + wsv.CAN1 + wsv.CAN2 + wsv.CAN3 + wsv.NJ2 +
             wsv.NJ3 +
             wsv.NJ4 + wsv.AT1 + wsv.AT2 +
             wsv.AT3 + wsv.AT4 + wsv.AT5 + wsv.ATN1 + wsv.TX1 + wsv.CANADAH1 as [All]
      FROM (select ''all''                 business_type,
                   4    as               sort,
                   isnull(t.CA2, 0)      CA2,
                   isnull(t.CA3, 0)      CA3,
                   isnull(t.CA4, 0)      CA4,
                   isnull(t.CA5, 0)      CA5,
                   isnull(t.CA6, 0)      CA6,
                   isnull(t.CA7, 0)      CA7,
                   isnull(t.CA8, 0)      CA8,
                   isnull(t.CA9, 0)      CA9,
                   isnull(t.CA10, 0)     CA10,
                   isnull(t.CA11, 0)     CA11,
                   isnull(t.CAL2, 0)     CAL2,
                   isnull(t.CAN1, 0)     CAN1,
                   isnull(t.CAN2, 0)     CAN2,
                   isnull(t.CAN3, 0)     CAN3,
                   isnull(t.NJ2, 0)      NJ2,
                   isnull(t.NJ3, 0)      NJ3,
                   isnull(t.NJ4, 0)      NJ4,
                   isnull(t.AT1, 0)      AT1,
                   isnull(t.AT2, 0)      AT2,
                   isnull(t.AT3, 0)      AT3,
                   isnull(t.AT4, 0)      AT4,
                   isnull(t.AT5, 0)      AT5,
                   isnull(t.ATN1, 0)     ATN1,
                   isnull(t.TX1, 0)      TX1,
                   isnull(t.CANADAH1, 0) CANADAH1
            from (select t.warehouseCode,
                         sum(t.qty) qty
                  from (select
                            t.carriercode,
                            t.warehousecode,
                            t.qty
                        from (select
                                  tblc.carriercode,
                                  tbwe.warehousecode,
                                  tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier <> 7
                              union all
                              select
                                  tblc.carriercode,
                                  tbwe.warehousecode,
                                  tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID in (226)
                                and not exists(select 1
                                               from tblCloudWarehouseLabel tcwl
                                               where tcwl.OrderId = tblo.PayPalTxID
                                                 and tcwl.WarehouseId = tbls.AssignedTo
                                                 and tcwl.PickingListDownloadTime is not null)
                              union all
                              select
                                  tblc.carriercode,
                                  tbwe.warehousecode,
                                  tbld.qty
                              from tblorders tblo
                                       join tblOrderDetails tbld
                                            on tblo.storeid = tbld.storeid and tblo.ordernumber = tbld.ordernumber
                                       join tblshipments tbls on tbls.shipmentid = tbld.shipmentid
                                       join tblCarriers tblc on tbls.carrier = tblc.carrierid
                                       join tblstoreexts tbse on tblo.storeid = tbse.storeid
                                       join tblwarehouseexts tbwe on tbls.assignedto = tbwe.warehouseid
                              where tblo.orderstatus = 2
                                and tbld.itemstatus = 1
                                and tbls.status = 1
                                and tbls.CreationDate >= DATEADD(MONTH, -1, GETDATE())
                                and tbls.Carrier = 7
                                and tblo.StoreID not in (226)
                                and not exists(select 1
                                               from tbl_extra_shipping_file tesf
                                               where tesf.shipment_id = tbls.ShipmentID
                                                 and tesf.is_valid = 1
                                                 and merge_date_time is not null)) t) t
                  group by t.warehouseCode, t.CarrierCode) t PIVOT (SUM(t.qty) FOR [WarehouseCode] IN ("CA2","CA3","CA4","CA5","CA6","CA7","CA8","CA9","CA10","CA11","CAL2","CAN1","CAN2","CAN3","NJ2","NJ3","NJ4","AT1","AT2","AT3","AT4","AT5","ATN1","TX1","CANADAH1")) AS T) wsv) t
where t.business_type <> ''b2bcloudwh_sum''
order by t.sort, t.business_type','【WOS-监控】【CA时间2点AM】美国仓库待发单统计','larry_wu@gigacloudtech.com,haoxinyan@gigacloudtech.com,wanxin@gigacloudtech.com,wangyan@gigacloudtech.com,mabin@gigacloudtech.com,xukunming@gigacloudtech.com,lunjia.li@gigacloudtech.com,wang.xin@gigacloudtech.com,stella.tian@gigacloudtech.com','mingdi.zhang@gigacloudtech.com,lei.yan@gigacloudtech.com,wenbo.dou@gigacloudtech.com,chris.xu@gigacloudtech.com,uswarehouse@gigacloudtech.com,shishanshan@gigacloudtech.com,uswhcoordinator@gigacloudtech.com,logistics@gigacloudtech.com,yuanwen@gigacloudtech.com,zhanghanlin@gigacloudtech.com,zhanghuiwen@gigacloudtech.com,xiafei@gigacloudtech.com,liuchao@gigacloudtech.com','业务类型,物流方式,CA2,CA3,CA4,CA5,CA6,CA7,CA8,CA9,CA10,CA11,CAL2,CAN1,CAN2,CAN3,NJ2,NJ3,NJ4,AT1,AT2,AT3,AT4,AT5,ATN1,TX1,CANADAH1,[ALL]','15 2 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tbll.sales_order_number,
       case
           when tbll.carrier_id = 3 then N''FEDEX BUY LABEL失败''
           when tbll.carrier_id = 1 then N''UPS BUY LABEL失败''
           when tbll.carrier_id = 118 then N''AMAZON BUY LABEL失败''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       tod.ItemCode                                as sku
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tse.owner_platform = ''giga_3pl''
  and tse.StoreID not in (428, 429, 666, 168)
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and tbs.CreationDate > getdate() - 7
  and tbs.CreationDate < getdate() - 0.04
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode
union
select tul.orderId,
       N''FEDEX BUY LABEL失败'' AS workname,
       tul.errmessage,
       tod.ItemCode
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         inner join tblOrderDetails tod with (nolock)
                    on tbo.StoreID = tod.StoreID
                        and tbo.OrderNumber = tod.OrderNumber
                        and tod.ItemStatus <> 8
         left join tblShipments tbs with (nolock) on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tse.owner_platform = ''giga_3pl''
  and tul.HISLINEID > 455348556
  and tse.StoreID not in (428, 429, 666, 168)
  and tbo.createDate > getdate() - 7
  and tbo.createDate < getdate() - 0.04
  and tul.workstatus IN (0, 2, 4)
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tul.orderId, tul.errmessage, tod.ItemCode','【WOS-监控】大健云buy label失败
','csr_giga@gigacloudtech.com','songyinghui@gigacloudtech.com,xiafei@gigacloudtech.com,liuchao@gigacloudtech.com,sujiawei@gigacloudtech.com,zhaijianfeng@gigacloudtech.com,liniannian@gigacloudtech.com,shiyuanyuan@gigacloudtech.com,chenkailiang@gigacloudtech.com','订单号,label类型,错误信息,SKU','3 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES (' select  dealtime,workname,WORKCOUNT,OKCOUNT
from tuslogheader with(nolock) where workStatus in (2,4) and  (worktype in (49,51,52,53,58) or (WORKTYPE = 26 and storeid = 226)) ','【WOS-监控】【重要】云送仓接口调用异常','songyinghui@gigacloudtech.com','liuchao@gigacloudtech.com,xiafei@gigacloudtech.com,chenkailiang@gigacloudtech.com','dealTime,workName,workCount,okCount','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('    select t.DisplayName                          "StoreName",
                              t.warehouseCode                        "仓库CODE",
                              t.PayPalTxID                           "销售订单号",
                              t.createDate                           "订单进入系统的时间",
                              (select top 1 teso.created_date_time
                               from tbl_extra_shipping_operating teso with (nolock)
                                        join tbl_extra_shipping_orders tesor with (nolock)
                                             on teso.shipping_order_id = tesor.id and tesor.is_valid = 1 and
                                                teso.operating_type = 3 and tesor.sales_order_number = t.PayPalTxID and tesor.warehouse_id = t.AssignedTo
                               order by teso.created_date_time desc) "仓库备货时间",
                              replace(t.itemcode, ''-001'', '''')        itemcode,
                              t.Qty,
                              t.orderstatus,
                              t.ServiceLevel                         "卡车公司"
                       from (select tse.DisplayName,
                                    tor.PayPalTxID,
                                    convert(varchar(100), tor.createDate, 20) createDate,
                                    toss.orderstatus,
                                    tod.ItemCode,
                                    sum(tod.Qty)                              Qty,
                                    tbwe.warehouseCode,
                                    tbls.AssignedTo,
                                    tbls.ServiceLevel
                             from tblOrders tor with (nolock)
                                      join tblstoreExts tse with (nolock) on tor.StoreID = tse.StoreID
                                      join tblOrderDetails tod with (nolock)
                                           on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                                      join tblItemStatus tbli with (nolock) on tod.ItemStatus = tbli.ItemStatusID
                                      join tblshipments tbls with (nolock) on tod.ShipmentID = tbls.ShipmentID
                                      join tblWarehouseExts tbwe with (nolock) on tbls.AssignedTo = tbwe.warehouseId
                                      join tblCarriers tblc with (nolock) on tbls.Carrier = tblc.CarrierID
                                      join tblorderstatus toss with (nolock) on toss.OrderStatusID = tor.orderstatus
                             where 1 = 1
                               and tor.createDate >= ''2023-01-01''
                               and tor.createDate < getdate() - 5
                               and tor.OrderStatus not in (''32'', ''16'')
                               and tse.sales_platform in (''b2b_fbm'')
                               and tbls.Carrier = 7
                               and tbls.Status not in (4)
                               and tbwe.operation_mode = ''zy''
                               and tbwe.warehouseCode not in (''CAL1'')
                               and tbwe.status = 1
                             group by tse.DisplayName,
                                      tor.PayPalTxID,
                                      convert(varchar(100), tor.createDate, 20),
                                      toss.orderstatus,
                                      tod.ItemCode,
                                      tbwe.warehouseCode,
                                     tbls.AssignedTo,
                                      tbls.ServiceLevel) t
                       order by t.createDate DESC','【DRP-监控】B2B LTL长期未发单','pingtaikefu@gigacloudtech.com,uswhcoordinator@gigacloudtech.com,wuyating@gigacloudtech.com,lunjia.li@gigacloudtech.com,logistics@gigacloudtech.com','liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com','StoreName,仓库Code,销售订单号,订单进入系统的时间,仓库备货时间,itemcode,qty,orderstatus,卡车公司','0 19 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>B2B平台客服</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('    select t.DisplayName                          "StoreName",
                                                                    t.warehouseCode                        "仓库CODE",
                                                                    t.PayPalTxID                           "销售订单号",
                                                                    t.createDate                           "订单进入系统的时间",
                                                                    (select top 1 teso.created_date_time
                                                                     from tbl_extra_shipping_operating teso with (nolock)
                                                                              join tbl_extra_shipping_orders tesor with (nolock)
                                                                                   on teso.shipping_order_id = tesor.id and tesor.is_valid = 1 and
                                                                                      teso.operating_type = 3 and tesor.sales_order_number = t.PayPalTxID and tesor.warehouse_id = t.AssignedTo
                                                                     order by teso.created_date_time desc) "仓库备货时间",
                                                                    replace(t.itemcode, ''-001'', '''')        itemcode,
                                                                    t.Qty,
                                                                    t.orderstatus,
                                                                    t.ServiceLevel                         "卡车公司"
                                                             from (
                                                             select tse.DisplayName,
                                                                          tor.PayPalTxID,
                                                                          convert(varchar(100), tor.createDate, 20) createDate,
                                                                          toss.orderstatus,
                                                                          tod.ItemCode,
                                                                          sum(tod.Qty)                              Qty,
                                                                          tbwe.warehouseCode,
                                                                          tbls.AssignedTo,
                                                                          tbls.ServiceLevel
                                                                   from tblOrders tor with (nolock)
                                                                            join tblstoreExts tse with (nolock) on tor.StoreID = tse.StoreID
                                                                            join tblOrderDetails tod with (nolock)
                                                                                 on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                                                                            join tblItemStatus tbli with (nolock) on tod.ItemStatus = tbli.ItemStatusID
                                                                            join tblshipments tbls with (nolock) on tod.ShipmentID = tbls.ShipmentID
                                                                            join tblWarehouseExts tbwe with (nolock) on tbls.AssignedTo = tbwe.warehouseId
                                                                            join tblCarriers tblc with (nolock) on tbls.Carrier = tblc.CarrierID
                                                                            join tblorderstatus toss with (nolock) on toss.OrderStatusID = tor.orderstatus
                                                                   where 1 = 1
                                                                     and tor.createDate >= ''2023-01-01''
                                                                     and tor.createDate < getdate() - 5
                                                                     and tse.sales_platform not in (''b2b_fbm'',''b2b_batch_cloud_fbm'',''dajian_wayfair_fbm'',''dajian_fbm'',''amazon_vc_wholesale_fbm'')
                                                                     and tbls.Carrier = 7
                                                                     and tbls.Status not in (4)
                                                                     and tbwe.operation_mode = ''zy''
                                                                     and tbwe.warehouseCode not in (''CAL1'')
                                                                     and tbwe.status = 1
                                                                     and tor.OrderStatus not in (32, 16, 4)
                                                                   group by tse.DisplayName,
                                                                            tor.PayPalTxID,
                                                                            convert(varchar(100), tor.createDate, 20),
                                                                            toss.orderstatus,
                                                                            tod.ItemCode,
                                                                            tbwe.warehouseCode,
                                                                            tbls.AssignedTo,
                                                                            tbls.ServiceLevel
                                                                   union all
                                                                       select tse.DisplayName,
                                                                          tor.PayPalTxID,
                                                                          convert(varchar(100), tor.createDate, 20) createDate,
                                                                          toss.orderstatus,
                                                                          tod.ItemCode,
                                                                          sum(tod.Qty)                              Qty,
                                                                          tbwe.warehouseCode,
                                                                          tbls.AssignedTo,
                                                                          tbls.ServiceLevel
                                                                   from tblOrders tor with (nolock)
                                                                            join tblstoreExts tse with (nolock) on tor.StoreID = tse.StoreID
                                                                            join tblOrderDetails tod with (nolock)
                                                                                 on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                                                                            join tblItemStatus tbli with (nolock) on tod.ItemStatus = tbli.ItemStatusID
                                                                            join tblshipments tbls with (nolock) on tod.ShipmentID = tbls.ShipmentID
                                                                            join tblWarehouseExts tbwe with (nolock) on tbls.AssignedTo = tbwe.warehouseId
                                                                            join tblCarriers tblc with (nolock) on tbls.Carrier = tblc.CarrierID
                                                                            join tblorderstatus toss with (nolock) on toss.OrderStatusID = tor.orderstatus
                                                                   where 1 = 1
                                                                     and tor.createDate >= ''2023-01-01''
                                                                     and tor.createDate < getdate() - 5
                                                                     and (tor.OrderStatus in (4) and tor.UpdatedbyUser = 1)
                                                                     and tse.sales_platform not in (''b2b_fbm'',''b2b_batch_cloud_fbm'',''dajian_wayfair_fbm'',''dajian_fbm'',''amazon_vc_wholesale_fbm'')
                                                                     and tbls.Carrier = 7
                                                                     and tbwe.operation_mode = ''zy''
                                                                     and tbwe.warehouseCode not in (''CAL1'')
                                                                     and tbwe.status = 1
                                                                   group by tse.DisplayName,
                                                                            tor.PayPalTxID,
                                                                            convert(varchar(100), tor.createDate, 20),
                                                                            toss.orderstatus,
                                                                            tod.ItemCode,
                                                                            tbwe.warehouseCode,
                                                                            tbls.AssignedTo,
                                                                            tbls.ServiceLevel
                                                                   ) t
                                                             order by t.createDate DESC ','【DRP-监控】自营 LTL长期未发单','suzhou_CSR@gigacloudtech.com,salesreport@gigacloudtech.com,uswhcoordinator@gigacloudtech.com,wuyating@gigacloudtech.com,lunjia.li@gigacloudtech.com,logistics@gigacloudtech.com','liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com','StoreName,仓库Code,销售订单号,订单进入系统的时间,仓库备货时间,itemcode,qty,orderstatus,卡车公司','0 19 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>苏州客服</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select ROW_NUMBER() OVER (ORDER BY temp.sales_order_number) as "No.",
       temp.sales_order_number                              as "Sales Order Number",
       temp.ServiceLevel                                    as "Truck",
       temp.warehouseCode                                   as "Warehouse",
       temp.comment                                         as "Reason"
from (select teso.sales_order_number,
             rslm.ServiceLevel,
             twe.warehouseCode,
             case operating_type
                 when 20 then ''shipping label or BOL file abnormal''
                 else ''The warehouse has intercepted the order'' end as comment
      from tbl_extra_shipping_orders teso with (nolock)
               inner join tbl_extra_shipping_operating tesot with (nolock) on teso.id = tesot.shipping_order_id
               inner join RServiceLevelMapping rslm with (nolock)
                          on teso.carrier_service_level_id = rslm.id and rslm.Carrier = 7
               inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = teso.warehouse_id
               inner join tblOrders tbo with (nolock)
                          on tbo.StoreID = teso.store_id and tbo.PayPalTxID = teso.sales_order_number
      where operating_type in (20, 21)
        and not exists(select 1
                       from tbl_extra_shipping_orders teso1 with (nolock)
                       where teso1.sales_order_number = teso.sales_order_number
                         and teso1.store_id = teso.store_id
                         and teso1.shipping_status in (4, 5)
                         and teso1.carrier_service_level_id = teso.carrier_service_level_id
                         and teso1.warehouse_id = teso.warehouse_id)
        and tbo.OrderStatus not in (16, 32)) temp','【DRP-监控】卡车备货异常监控','songyinghui@gigacloudtech.com,shishanshan@gigacloudtech.com,uswhcoordinator@gigacloudtech.com','chenkailiang@gigacloudtech.com,chenhuizhu@gigacloudtech.com,liuchao@gigacloudtech.com,linda.xie@gigacloudtech.com','NO.,Sales Order Number,Truck,Warehouse,Reason','0 19 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>石珊珊</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tse.DisplayName,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel != ''UPS Roadie Ground''
  and tse.OrdersFrom = ''Oristand''
  and tse.StoreID not in
      (300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320,
       321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341,
       342, 343, 344, 345, 346, 347, 348)
  and tbs.CreationDate > getdate() - 20
  and tbs.CreationDate < getdate() - 0.1
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus
union
select tse.DisplayName,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus                            as orderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock)
                   on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tbo.createDate > getdate() - 20
  and tbo.createDate < getdate() - 0.1
  and tul.HISLINEID > 455348556
  and tse.OrdersFrom = ''Oristand''
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tse.StoreID not in
      (300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320,
       321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341,
       342, 343, 344, 345, 346, 347, 348)
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tse.StoreID, tse.DisplayName, tul.orderId, tul.errmessage, toss.OrderStatus','FedEx、UPS、Amazon Buy Label失败','US_yunying@gigacloudtech.com,suzhou_csr@gigacloudtech.com','chenhuizhu@gigacloudtech.com,liuchao@gigacloudtech.com,songyinghui@gigacloudtech.com,sujiawei@gigacloudtech.com,zhaijianfeng@gigacloudtech.com,liniannian@gigacloudtech.com,shiyuanyuan@gigacloudtech.com,chenkailiang@gigacloudtech.com,yuebeibei@gigacloudtech.com,uswhcoordinator@gigacloudtech.com','From,OrderId（销售订单号）,DealTime,WorkName,Info,OrderStatus','0 2,8,14,20 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>美国客服</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select t.OrderId,t.PO,t.Line from tblWalmartOrderTemp t group by t.OrderId,t.PO,t.Line having count(*)>1','【WOS-监控】[重要]Walmart临时表订单重复报警','liuchao@gigacloudtech.com','chenkailiang@gigacloudtech.com','OrderId,Po,line','50 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>刘超,閤飞</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tblw.WarehouseCode                 ''From'',
       ''YiCang''                           ''To'',
       case tul.programCode
           when ''1111'' then ''Fail''
           when ''1112'' then ''Success_Urgent''
           when ''1113'' then ''Warning'' end Result,
       tul.orderId                        PayPalTxId,
       tul.shipmentId                     ShipmentId,
       tul.errMessage                     Message,
       tul.CREATIONDATE                   CreationDate
from tuslogline tul with (nolock)
         left join tuslogheader tuh with (nolock) on tul.hisId = tuh.hisId
         left join tblorders tblo with (nolock) on tblo.PayPalTxId = tul.orderId
         left join tblorderdetails tbld with (nolock) on tbld.ordernumber = tblo.ordernumber and tbld.storeid = tblo.storeid and tul.shipmentid = tbld.shipmentid
         left join tblShipments tbls with (nolock) on tbls.StoreID = tbld.StoreID and tbls.OrderNumber = tbld.OrderNumber and
                                        tbld.shipmentid = tbls.shipmentid
         join tblWarehouses tblw with (nolock) on tblw.WarehouseID = tbls.AssignedTo
where tul.hisId in (select top 2 header.hisId
                    from tuslogheader header with (nolock)
                    where header.workType = ''74''
                      and header.CREATIONDATE > getdate() - 1
                      and header.WORKSTATUS = 2
                    order by header.CREATIONDATE desc)
  and tul.ERRMESSAGE not like ''%no shipment label%''
  and tul.ERRMESSAGE not like ''%serviceType is null%''
  and tul.programCode != ''0000''
order by tul.programCode desc, tuh.CREATIONDATE desc','【DRP-监控】【重要】外部仓库（易仓）对接订单异常','shishanshan@gigacloudtech.com,shenling@gigacloudtech.com','drp_us_it@gigacloudtech.com,pingtaikefu@gigacloudtech.com','From,To,Result,PayPalTxId,ShipmentId,Message,CreationDate','45 21 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>陈开亮</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select distinct
                       ta.sales_order_number
                   from tbl_item_code_attachment ta with(nolock)
                            join tblorders tblo with(nolock) on ta.sales_order_number=tblo.PayPalTxID
                   where  tblo.OrderStatus  = 2 and tblo.createDate>''2021-07-08 02:06:14.107''
                     and ta.carrier_service_level_code like ''%Overnight%'' and tblo.storeid in(205,212,276,277)','Being Process的Overnight订单','pingtaikefu@gigacloudtech.com','songyinghui@gigacloudtech.com,chenkailiang@gigacloudtech.com,liuchao@gigacloudtech.com,chenhuizhu@gigacloudtech.com','订单号','0 20 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>平台客服</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tblw.WarehouseCode                 ''From'',
       ''YiCang''                           ''To'',
       case tul.programCode
           when ''1111'' then ''Fail''
           when ''1112'' then ''Success_Urgent''
           when ''1113'' then ''Warning'' end Result,
       tul.orderId                        PayPalTxId,
       tul.shipmentId                     ShipmentId,
       tul.errMessage                     Message,
       tul.CREATIONDATE                   CreationDate
from tuslogline tul with (nolock)
         left join tuslogheader tuh with (nolock) on tul.hisId = tuh.hisId
         left join tblorders tblo with (nolock) on tblo.PayPalTxId = tul.orderId
         left join tblorderdetails tbld with (nolock) on tbld.ordernumber = tblo.ordernumber and tbld.storeid = tblo.storeid and tul.shipmentid = tbld.shipmentid
         left join tblShipments tbls with (nolock) on tbls.StoreID = tbld.StoreID and tbls.OrderNumber = tbld.OrderNumber and
                                        tbld.shipmentid = tbls.shipmentid
         join tblWarehouses tblw with (nolock) on tblw.WarehouseID = tbls.AssignedTo
where tul.hisId in (select top 1 header.hisId
                    from tuslogheader header with (nolock)
                    where header.workType = ''73''
                      and header.CREATIONDATE > getdate() - 1
                    order by header.CREATIONDATE desc)
  and tul.ERRMESSAGE not like ''%no shipment label%''
  and tul.ERRMESSAGE not like ''%serviceType is null%''
  and tul.programCode != ''0000''
order by tul.programCode desc, tuh.CREATIONDATE desc','【DRP-监控】【重要】ATX4仓库（易仓）对接订单异常','shishanshan@gigacloudtech.com,shenling@gigacloudtech.com,liuchao@gigacloudtech.com','drp_us_it@gigacloudtech.com,pingtaikefu@gigacloudtech.com','From,To,Result,PayPalTxId,ShipmentId,Message,CreationDate','45 21 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>陈开亮</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select distinct tor.PayPalTxID     ''销售订单号'',
                                                      thi.item_code      ''冻结SKU'',
                                                      tse.warehouseCode ''冻结仓库'',
                                                      thi.qty            ''冻结库存'',
                                                      tor.createDate     ''订单创建时间''
                                      from tblorders tor with (nolock)
                                               inner join tblOrderDetails tod with (nolock) on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                                               inner join tbl_hold_inventory thi with (nolock) on thi.item_code + ''-001'' = tod.ItemCode
                                               inner join tblWarehouseExts tse with (nolock) on thi.warehouse_id = tse.warehouseId
                                      where tor.createDate > getdate() -30
                                        and tor.createDate < getdate() -0.1
                                        and tor.OrderStatus = 1
                                      order by tor.createDate DESC','new order订单有冻结库存','songyinghui@gigacloudtech.com,zhangyumeng@gigacloudtech.com,chengguangkuo@gigacloudtech.com','chenkailiang@gigacloudtech.com,liuchao@gigacloudtech.com','销售订单号,冻结SKU,冻结仓库,冻结库存,订单创建时间','10 2 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>程广阔</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select *
from (select distinct tse.DisplayName as                                   ''店铺'',
                      tor.PayPalTxID  as                                   ''OrderID'',
                      tod.ItemCode,
                      tos.OrderStatus,
                      tor.createDate  as                                   ''订单导入时间'',
                      tor.OrderDate   as                                   ''订单销售时间'',
                      tica.warehouse_id,
                      twe.warehouseCode,
                      case
                          when tica.deal_status <> 1 and isnull(tica.source_file_url, '''') = '''' and warehouse_id is null
                              then N''未指定仓库并且无label''
                          when tica.deal_status <> 1 and isnull(tica.source_file_url, '''') = '''' and
                               warehouse_id is not null
                              then N''无label''
                          when tica.deal_status <> 1 and isnull(tica.source_file_url, '''') <> '''' and
                               isnull(tica.carrier_code, '''') = '''' and
                               (charindex(''does not resolve the tracking number'', tica.memo) > 0 or
                                charindex(''find matched'', tica.memo) > 0) then N''异常label''

                          when tica.deal_status = 1 and source_file_url is null and
                               (charindex(''does not resolve the tracking number'', tica.memo) > 0 or
                                charindex(''find matched'', tica.memo) > 0) and tica.carrier_service_level_id is null
                              then N''异常label''
                          when deal_status = 2 and tica.memo = ''_two trck not equal'' then N''运单号不一致''
                          when warehouse_id is null then N''未指定仓库''
                          when tica.deal_status <> 1 and (charindex(''erver error'', tica.memo) > 0
                              or charindex(''found service from Enum'', tica.memo) > 0
                              or charindex(''find service from FedEx'', tica.memo) > 0
                              or charindex(''find service from UPS'', tica.memo) > 0
                              or charindex(''tracking number corresponds'', tica.memo) > 0
                              or charindex('' can not find service '', tica.memo) > 0
                              ) then N''查不到物流服务''
                          when tica.deal_status <> 1 and charindex(''Label file blank space is too large'', tica.memo) > 0
                              then N''异常label''
                          when tse.shipping_fee_type = ''pick_up_account_buy_fee'' and tor.address_type is null
                              then N''地址校验失败''
                          else (select top 1 comment
                                from tbl_order_transaction_audit_trail totat with (nolock)
                                where totat.store_id = tor.storeid
                                  and totat.sales_order_number = tor.PayPalTxID
                                  and operation_type = 12
                                  and totat.created_date_time > getdate() - 60
                                order by totat.created_date_time desc) end ''备注'',
                      N''上门取货''     as                                   ''订单类型''
      from tblorders tor with (nolock)
               inner join tblOrderDetails tOD with (nolock)
                          on tor.StoreID = tOD.StoreID and tor.OrderNumber = tOD.OrderNumber
               left join tbl_item_code_attachment tica
                         on tica.sales_order_number = tor.PayPalTxID and tod.ItemNumber = tica.line_item_number
               left join tblWarehouseExts twe with (nolock) on twe.warehouseId = tica.warehouse_id
               inner join tblstoreExts tse with (nolock) on tse.StoreID = tor.StoreID
               inner join tblOrderStatus tos with (nolock) on tor.OrderStatus = tos.OrderStatusID
               left join tblshipments tss with (nolock) on tss.ShipmentID = tod.ShipmentID
      where 1 = 1
        and createDate >= getdate() - 60
        and tor.orderstatus not in (16, 32)
        and tod.ItemStatus <> 8
        and tod.ShipmentID is null
        and createDate <= getdate() - 0.5
        and tse.sales_platform not in (''dajian_fbm'', ''dajian_wayfair_fbm'')
        and tse.shipping_fee_type in
            (''pick_up_buyer_upload_fee'', ''pick_up_account_buy_fee'', ''buyer_pick_up_account_buy_fee'')
        and tse.StoreID not in (325)
      union all
      select distinct tse.DisplayName                         as ''店铺'',
                      tor.PayPalTxID                          as ''OrderID'',
                      tod.ItemCode,
                      tos.OrderStatus,
                      tor.createDate                          as ''订单导入时间'',
                      tor.OrderDate                           as ''订单销售时间'',
                      null,
                      null,
                      (select top 1 comment
                       from tbl_order_transaction_audit_trail totat with (nolock)
                       where totat.store_id = tor.storeid
                         and totat.sales_order_number = tor.PayPalTxID
                         and operation_type = 12
                         and totat.created_date_time > getdate() - 60
                       order by totat.created_date_time desc) as ''备注'',
                      N''一件代发''                             as ''订单类型''
      from tblorders tor with (nolock)
               inner join tblOrderDetails tOD with (nolock)
                          on tor.StoreID = tOD.StoreID and tor.OrderNumber = tOD.OrderNumber
               inner join tblstoreExts tse with (nolock) on tse.StoreID = tor.StoreID
               inner join tblOrderStatus tos with (nolock) on tor.OrderStatus = tos.OrderStatusID
               left join tblshipments tss with (nolock) on tss.ShipmentID = tod.ShipmentID
      where 1 = 1
        and createDate >= getdate() - 60
        and tor.orderstatus not in (16, 32)
        and tod.ShipmentID is null
        and tod.ItemStatus <> 8
        and createDate <= getdate() - 0.5
        and tse.sales_platform not in (''dajian_fbm'', ''dajian_wayfair_fbm'')
        and tod.ShipmentID is null
        and tse.shipping_fee_type = ''drop_shipping_account_buy_fee''
        and tse.StoreID not in (325)) temp
where 1 = 1
order by temp.订单类型, temp.订单导入时间, temp.OrderID','22年10月1日之后未分单数据','chenkailiang@gigacloudtech.com','liuchao@gigacloudtech.com,shenzhenxing@gigacloudtech.com,sujiawei@gigacloudtech.com,zhaijianfeng@gigacloudtech.com,its@gigacloudtech.com','店铺,销售订单号,SKU,订单状态,订单导入时间,订单销售时间,仓库id,仓库code,备注,订单类型','12 2,8,14,20 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>宋颖慧,刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select distinct
                                         ta.sales_order_number
                                     from tbl_item_code_attachment ta with(nolock)
                                              join tblorders tblo with(nolock) on ta.sales_order_number=tblo.PayPalTxID
                                     where  tblo.OrderStatus  = 2 and tblo.createDate>''2022-11-01 00:00:00.000''
                                       and ta.carrier_service_level_code like ''%Overnight%'' and tblo.storeid in(208);','Being Process的Overnight订单','shishanshan@gigacloudtech.com','songyinghui@gigacloudtech.com,chenkailiang@gigacloudtech.com,liuchao@gigacloudtech.com,chenhuizhu@gigacloudtech.com','订单号','0 20 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>石珊珊</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select t.DisplayName                          "StoreName",
                                                 t.warehouseCode                        "仓库CODE",
                                                 t.PayPalTxID                           "销售订单号",
                                                 t.createDate                           "订单进入系统的时间",
                                                 (select top 1 teso.created_date_time
                                                  from tbl_extra_shipping_operating teso with (nolock)
                                                           join tbl_extra_shipping_orders tesor with (nolock)
                                                                on teso.shipping_order_id = tesor.id and tesor.is_valid = 1 and
                                                                   teso.operating_type = 3 and tesor.sales_order_number = t.PayPalTxID  and tesor.warehouse_id = t.AssignedTo
                                                  order by teso.created_date_time desc) "仓库备货时间",
                                                 replace(t.itemcode, ''-001'', '''')        itemcode,
                                                 t.Qty,
                                                 t.orderstatus,
                                                 t.ServiceLevel                         "卡车公司"
                                          from (
                                          select tse.DisplayName,
                                                       tor.PayPalTxID,
                                                       convert(varchar(100), tor.createDate, 20) createDate,
                                                       toss.orderstatus,
                                                       tod.ItemCode,
                                                       sum(tod.Qty)                              Qty,
                                                       tbwe.warehouseCode,
                                                       tbls.AssignedTo,
                                                       tbls.ServiceLevel
                                                from tblOrders tor with (nolock)
                                                         join tblstoreExts tse with (nolock) on tor.StoreID = tse.StoreID
                                                         join tblOrderDetails tod with (nolock)
                                                              on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                                                         join tblItemStatus tbli with (nolock) on tod.ItemStatus = tbli.ItemStatusID
                                                         join tblshipments tbls with (nolock) on tod.ShipmentID = tbls.ShipmentID
                                                         join tblWarehouseExts tbwe with (nolock) on tbls.AssignedTo = tbwe.warehouseId
                                                         join tblCarriers tblc with (nolock) on tbls.Carrier = tblc.CarrierID
                                                         join tblorderstatus toss with (nolock) on toss.OrderStatusID = tor.orderstatus
                                                where 1 = 1
                                                  and tor.createDate >= ''2023-01-01''
                                                  and tor.createDate < getdate() - 5
                                                  and tse.sales_platform in (''dajian_wayfair_fbm'',''dajian_fbm'')
                                                  and tbls.Carrier = 7
                                                  and tbls.Status not in (4)
                                                  and tbwe.operation_mode = ''zy''
                                                  and tbwe.warehouseCode not in (''CAL1'')
                                                  and tbwe.status = 1
                                                  and tor.OrderStatus not in (32, 16)
                                                group by tse.DisplayName,
                                                         tor.PayPalTxID,
                                                         convert(varchar(100), tor.createDate, 20),
                                                         toss.orderstatus,
                                                         tod.ItemCode,
                                                         tbwe.warehouseCode,
                                                         tbls.AssignedTo,
                                                         tbls.ServiceLevel
                                                ) t
                                          order by t.createDate DESC','【DRP-监控】3PL LTL长期未发单','suzhou_CSR@gigacloudtech.com,uswhcoordinator@gigacloudtech.com,wuyating@gigacloudtech.com,lunjia.li@gigacloudtech.com,csr_giga@gigacloudtech.com','chenkailiang@gigacloudtech.com,liuchao@gigacloudtech.com','StoreName,仓库Code,销售订单号,订单进入系统的时间,仓库备货时间,itemcode,qty,orderstatus,卡车公司','0 19 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>3PL客服</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('-- fedex
-- 上门取货买单
select N''上门取货买单FedEx'',
       tc.sales_order_number,
       tc.tracking_number,
       tc.warehouse_id,
       twe.warehouseCode,
       tf.payment_type,
       tf.payor_account_number as N''实际使用的付款账号'',
       msp.fedexAccountNumber  as N''应该使用的付款账号'',
       tf.carrier_id              N''实际使用的CarrierId'',
       mw.fedexCarrierId          N''应该使用的CarrierId''
from tbl_common_shipping_file tc with (nolock)
         inner join tblstoreExts tse with (nolock) on tc.store_id = tse.StoreID
         inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = tc.warehouse_id
         inner join tbl_fedex_shipping_fee tf with (nolock) on tc.file_id = tf.common_shipping_file_id
         inner join musWarehouseParameter mw with (nolock) on tc.warehouse_id = mw.warehouseId
         inner join musStoreWarehouShipAccountParameter msp with (nolock)
                    on msp.storeId = tc.store_id and msp.warehouseId = tc.warehouse_id
where tc.create_date_time > getdate() - 1
  and tc.warehouse_id != 66
  and tc.store_id not in (250, 260, 270, 280, 199, 195)
  and tse.shipping_fee_type not in (''drop_shipping_account_buy_fee'')
  and (mw.fedexCarrierId != tf.carrier_id or tf.payment_type = ''SENDER'' or tf.payor_account_number is null)
union all
-- b2b代买买单
select N''b2b代买FedEx'',
       tc.sales_order_number,
       tc.tracking_number,
       tc.warehouse_id,
       twe.warehouseCode,
       tf.payment_type,
       tf.payor_account_number                     as N''实际使用的付款账号'',
       (select top 1 yzc.payAccountNumber
        from tblYzcOrders yzc with (nolock)
        where yzc.StoreID = tse.StoreID
          and yzc.OrderID = tc.sales_order_number) as N''应该使用的付款账号'',
       tf.carrier_id                                  N''实际使用的CarrierId'',
       mw.fedexCarrierId                              N''应该使用的CarrierId''
from tbl_common_shipping_file tc with (nolock)
         inner join tblstoreExts tse with (nolock) on tc.store_id = tse.StoreID
         inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = tc.warehouse_id
         inner join tbl_fedex_shipping_fee tf with (nolock) on tc.file_id = tf.common_shipping_file_id
         inner join musWarehouseParameter mw with (nolock) on tc.warehouse_id = mw.warehouseId
where tc.create_date_time > getdate() - 1
  and tc.warehouse_id != 66
  and tc.store_id in (250, 260, 270, 280)
  and (mw.fedexCarrierId != tf.carrier_id or tf.payment_type = ''SENDER'' or tf.payor_account_number is null)

union all
-- 3pl代买买单
select N''3pl代买FedEx'',

       tc.sales_order_number,
       tc.tracking_number,
       tc.warehouse_id,
       twe.warehouseCode,
       tf.payment_type,
       tf.payor_account_number as                             N''实际使用的付款账号'',
       (select asodis.shipping_bill_account as N''应该使用的付款账号''
        from api_sales_order aso with (nolock)
                 inner join api_sales_order_goods asog with (nolock) on aso.aso_head_id = asog.aso_head_id
                 inner join api_sales_order_dap_goods asodg with (nolock) on asodg.asog_line_id = asog.asog_line_id
                 inner join api_sales_order_dap_item asodi with (nolock) on asodi.asodg_line_id = asodg.asodg_line_id
                 inner join api_sales_order_dap_item_shipping asodis with (nolock)
                            on asodis.asodi_line_id = asodi.asodi_line_id
        where aso.drp_id = tc.store_id
          and aso.sales_order_number = tc.sales_order_number) payAccountNumber,
       tf.carrier_id                                          N''实际使用的CarrierId'',
       mw.fedexCarrierId                                      N''应该使用的CarrierId''
from tbl_common_shipping_file tc with (nolock)
         inner join tblstoreExts tse with (nolock) on tc.store_id = tse.StoreID
         inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = tc.warehouse_id
         inner join tbl_fedex_shipping_fee tf with (nolock) on tc.file_id = tf.common_shipping_file_id
         inner join musWarehouseParameter mw with (nolock) on tc.warehouse_id = mw.warehouseId
where tc.create_date_time > getdate() - 1
  and tc.warehouse_id != 66
  and tc.store_id = 199
  and (mw.fedexCarrierId != tf.carrier_id or tf.payment_type = ''SENDER'' or tf.payor_account_number is null
    )

union all
-- ups
-- 上门取货买单

select N''上门取货买单UPS'',
       tc.sales_order_number,
       tc.tracking_number,
       tc.warehouse_id,
       twe.warehouseCode,
       tf.shipper_type,
       tf.pay_account_number                                            as N''实际使用的付款账号'',
       isnull(isnull(tse.upsAccountNumber, null), msp.upsAccountNumber) as N''应该使用的付款账号'',
       tf.carrier_id                                                       N''实际使用的CarrierId'',
       mw.fedexCarrierId                                                   N''应该使用的CarrierId''
from tbl_common_shipping_file tc with (nolock)
         inner join tblstoreExts tse with (nolock) on tc.store_id = tse.StoreID
         inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = tc.warehouse_id
         inner join tbl_ups_shipping_fee tf with (nolock) on tc.file_id = tf.common_shipping_file_id
         inner join musWarehouseParameter mw with (nolock) on tc.warehouse_id = mw.warehouseId
         inner join musStoreWarehouShipAccountParameter msp with (nolock)
                    on msp.storeId = tc.store_id and msp.warehouseId = tc.warehouse_id
where tc.create_date_time > getdate() - 1
  and tc.warehouse_id != 66
  and tc.store_id not in (250, 260, 270, 280, 199, 195)
  and tse.shipping_fee_type not in (''drop_shipping_account_buy_fee'')
  and (mw.upsCarrierId != tf.carrier_id or tf.shipper_type = ''Comptree'' or tf.pay_account_number is null)
union all
-- b2b代买买单

select N''b2b代买UPS'',
       tc.sales_order_number,
       tc.tracking_number,
       tc.warehouse_id,
       twe.warehouseCode,
       tf.shipper_type,
       tf.pay_account_number                       as N''实际使用的付款账号'',
       (select top 1 yzc.payAccountNumber
        from tblYzcOrders yzc with (nolock)
        where yzc.StoreID = tse.StoreID
          and yzc.OrderID = tc.sales_order_number) as N''应该使用的付款账号'',
       tf.carrier_id                                  N''实际使用的CarrierId'',
       mw.fedexCarrierId                              N''应该使用的CarrierId''
from tbl_common_shipping_file tc with (nolock)
         inner join tblstoreExts tse with (nolock) on tc.store_id = tse.StoreID
         inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = tc.warehouse_id
         inner join tbl_ups_shipping_fee tf with (nolock) on tc.file_id = tf.common_shipping_file_id
         inner join musWarehouseParameter mw with (nolock) on tc.warehouse_id = mw.warehouseId
where tc.create_date_time > getdate() - 1
  and tc.warehouse_id != 66
  and tc.store_id in (250, 260, 270, 280)
  and (mw.upsCarrierId != tf.carrier_id or tf.shipper_type = ''Comptree'' or tf.pay_account_number is null)
union all
-- 3pl代买买单
select N''3pl代买UPS'',
       tc.sales_order_number,
       tc.tracking_number,
       tc.warehouse_id,
       twe.warehouseCode,
       tf.shipper_type,
       tf.pay_account_number                                  as N''实际使用的付款账号'',
       (select asodis.shipping_bill_account as shippingBillAccount
        from api_sales_order aso with (nolock)
                 inner join api_sales_order_goods asog with (nolock) on aso.aso_head_id = asog.aso_head_id
                 inner join api_sales_order_dap_goods asodg with (nolock) on asodg.asog_line_id = asog.asog_line_id
                 inner join api_sales_order_dap_item asodi with (nolock) on asodi.asodg_line_id = asodg.asodg_line_id
                 inner join api_sales_order_dap_item_shipping asodis with (nolock)
                            on asodis.asodi_line_id = asodi.asodi_line_id
        where aso.drp_id = tc.store_id
          and aso.sales_order_number = tc.sales_order_number) as N''应该使用的付款账号'',
       tf.carrier_id                                             N''实际使用的CarrierId'',
       mw.fedexCarrierId                                         N''应该使用的CarrierId''
from tbl_common_shipping_file tc with (nolock)
         inner join tblstoreExts tse with (nolock) on tc.store_id = tse.StoreID
         inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = tc.warehouse_id
         inner join tbl_ups_shipping_fee tf with (nolock) on tc.file_id = tf.common_shipping_file_id
         inner join musWarehouseParameter mw with (nolock) on tc.warehouse_id = mw.warehouseId
where tc.create_date_time > getdate() - 1
  and tc.warehouse_id != 66
  and tc.store_id = 199
  and (mw.upsCarrierId != tf.carrier_id or tf.shipper_type = ''Comptree'' or tf.pay_account_number is null
    )','DRP系统买单账号使用异常统计','liuchao@gigacloudtech.com','chenkailiang@gigacloudtech.com,xiafei@gigacloudtech.com,chenhuizhu@gigacloudtech.com','买单类型,订单号,运单号,仓库id,仓库code,付款类型,实际使用的付款账号,应该使用的付款账号,实际使用的CarrierId,应该使用的CarrierId','10 4,12,20 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select ts.DisplayName                                                                               ''店铺名'',
       tblo.PayPalTxID                                                                              ''销售订单号'',
       twe.warehouseCode,
       case tbls.Carrier when 1 then ''UPS'' when 3 then ''FEDEX'' when 7 then ''TRUCK'' else null end as ''Carrier'',
       tos.OrderStatus,
       tis.Description                                                                              ''ItemSatus'',
       REPLACE(tod.ItemCode, ''-001'', '''')                                                            ItemCode,
       tcsf.tracking_number,
       tod.Qty,
       tblo.createDate                                                                              ''订单进系统时间'',
       case
           when shipping_fee_type = ''drop_shipping_account_buy_fee'' then N''一件代发''
           when shipping_fee_type in (''pick_up_account_buy_fee'', ''pick_up_buyer_upload_fee'') then N''上门取货''
           else '''' end                                                                           as ''类型''
from tblOrders tblo with (nolock)
         join tblOrderDetails tod with (nolock) on tod.StoreID = tblo.StoreID and tod.OrderNumber = tblo.OrderNumber
         left join tblShipments tbls with (nolock) on tod.ShipmentID = tbls.ShipmentID
         left join tbl_common_shipping_file tcsf with (nolock) on tcsf.shipment_id = tbls.ShipmentID
         left join tblItemStatus tis with (nolock) on tis.ItemStatusID = tod.ItemStatus
         join tblOrderStatus tos with (nolock) on tos.OrderStatusID = tblo.OrderStatus
         join tblstoreExts ts with (nolock) on tblo.StoreID = ts.StoreID
         left join tblWarehouseExts twe with (nolock) on twe.warehouseId = tbls.AssignedTo
where tbls.AssignedTo in (78, 80, 88, 90, 92, 94, 98, 100, 102, 104, 106, 108, 116, 118, 126, 128, 150, 152, 162, 164)
  and tblo.StoreID not in (256)
  and tbls.Status not in (2, 4, 8)
  and tblo.OrderStatus not in (4, 16, 32)
  and tblo.createDate > getdate() - 30
  and tbls.CreationDate < GETDATE() - 3
  and tcsf.tracking_number is not null
order by twe.warehouseCode, ts.shipping_fee_type, tblo.createDate, tblo.PayPalTxID','【DRP-监控】合作仓订单超3天未推送','liuchao@gigacloudtech.com,shishanshan@gigacloudtech.com','sujiawei@gigacloudtech.com,zhaijianfeng@gigacloudtech.com,chenkailiang@gigacloudtech.com','店铺名,销售订单号,仓库,物流,订单状态,ItemSatus,ItemCode,运单号,数量,订单进系统时间,类型','0 2,10,18 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>石珊珊,刘超</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select twe.warehouseCode                 as ''仓库code'',
       tbo.PayPalTxID                    as ''销售订单号'',
       tbo.OrderID                       as ''系统订单号'',
       case
           when tse.shipping_fee_type = ''drop_shipping_account_buy_fee'' then N''一件代发''
           when tse.shipping_fee_type in (''pick_up_account_buy_fee'', ''pick_up_buyer_upload_fee'') then N''上门取货''
           when tse.shipping_fee_type in (''buyer_pick_up_account_buy_fee'') then N''上门自提''
           else tse.shipping_fee_type end                   as ''订单类型'',
       tbt.TrackingNumber                as ''运单号'',
       REPLACE(tod.ItemCode, ''-001'', '''') as ''Item code'',
       totat.created_date_time           as ''订单推送日期''
from tblOrders tbo with (nolock)
         left join tblOrderDetails tod with (nolock) on tbo.StoreID = tod.StoreID
    and tod.OrderNumber = tbo.OrderNumber
         left join tblShipments tbs with (nolock) on tbs.ShipmentID = tod.ShipmentID
         left join tblTracking tbt with (nolock) on tbs.ShipmentID = tbt.ShipmentID
         left join tblstoreExts tse with (nolock) on tbo.StoreID = tse.StoreID
         left join tblWarehouseExts twe with (nolock) on tbs.AssignedTo = twe.warehouseId
         left join tbl_order_transaction_audit_trail totat with (nolock) on totat.store_id = tod.StoreID
    and totat.order_number = tod.OrderNumber and totat.item_number = tod.ItemNumber
where tbs.AssignedTo in (78, 80, 88, 90, 92, 94, 98, 100, 102, 104, 106, 108, 116, 118, 126, 128, 150, 152, 162, 164)
  and tod.ItemStatus = 2
  and totat.operation_type = 13
  and totat.change_to = ''Shipping''
  and totat.created_date_time < getdate() - 3
order by twe.warehouseCode,totat.created_date_time asc','【DRP-监控】合作仓库超过3天未发货订单','uswhcoordinator@gigacloudtech.com','liuchao@gigacloudtech.com,xiafei@gigacloudtech.com,chenhuizhu@gigacloudtech.com,shishuwen@gigacloudtech.com,wanyuanqi@gigacloudtech.com,yuebeibei@gigacloudtech.com,zhaijianfeng@gigacloudtech.com','仓库code,销售订单号,系统订单号,订单类型,运单号,Item code,订单推送日期,类型','0 2 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>仓库联络员</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select toi.sales_order_number,
       tor.OrderID,
       convert(varchar(100), toi.create_date_time, 120),
       tos.OrderStatus
from tbl_order_intercept toi with (nolock)
         inner join tblorders tor with (nolock)
                    on toi.store_id = tor.StoreID and toi.sales_order_number = tor.PayPalTxID
         inner join tblOrderStatus tos on tos.OrderStatusID = tor.OrderStatus
where toi.create_date_time > DATEADD(HOUR, -1, GETDATE())
  and toi.deal_type = 1 and toi.data_source = ''B2B''
  and (
        toi.deal_date_time is null or toi.feedback_date_time is null or
        DATEDIFF(SECOND, toi.create_date_time, toi.feedback_date_time) > 15
    )','【取消超时】B2B调用DRP取消接口超时','xiafei@gigacloudtech.com,liuchao@gigacloudtech.com','chenkailiang@gigacloudtech.com','销售订单号,系统订单号,申请取消时间,订单状态','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select toi.sales_order_number,
       tor.OrderID,
       convert(varchar(100), toi.create_date_time, 120),
       case
           when toi.deal_type = 1 then N''取消''
           else N''拦截'' end as type,
       tos.OrderStatus,
       case
           when CHARINDEX(N''失败'', toi.memo) > 0 then N''失败''
           else N''成功'' end as result,
       toi.memo
from tbl_order_intercept toi with (nolock)
         left join tblorders tor with (nolock)
                    on toi.store_id = tor.StoreID and toi.sales_order_number = tor.PayPalTxID
         left join tblOrderStatus tos on tos.OrderStatusID = tor.OrderStatus
where toi.create_date_time > DATEADD(HOUR, -1, GETDATE())
  and toi.memo like N''%失败%''','【DRP-监控】B2B取消/拦截接口返回失败','xiafei@gigacloudtech.com,liuchao@gigacloudtech.com','chenkailiang@gigacloudtech.com','销售订单号,系统订单号,申请取消/拦截时间,操作类型,订单状态,B2B返回结果,B2B返回失败的msg','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select twe.warehouseCode,convert(varchar(10), max(created_date_time),120) latestSyncDate
from tbl_wms_pick_zone_inventory wpi
inner join tblWarehouseExts twe on twe.warehouseId = wpi.warehouse_id
where wpi.created_date_time < convert(varchar(10), GETDATE(), 120)
and wpi.created_date_time > GETDATE() -7
group by twe.warehouseCode
order by twe.warehouseCode','WMS库存及库位数据未及时同步到DRP','chenkailiang@gigacloudtech.com,liuchao@gigacloudtech.com,lizhenbiao@gigacloudtech.com','wanyuanqi@gigacloudtech.com','仓库CODE,库存最近同步日期','23 3 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tbo.PayPalTxID,
       tbs.DisplayName,
       tos.OrderStatus,
       FORMAT(tbo.OrderDate, ''yyyy-MM-dd HH:mm:ss'')  as orderDate,
       FORMAT(tbo.createDate, ''yyyy-MM-dd HH:mm:ss'') as createDate
from tblorders tbo with (nolock)
         left join tblShipments ts with (nolock) on tbo.StoreID = ts.StoreID and tbo.OrderNumber = ts.OrderNumber
         left join tblstoreExts tbs with (nolock) on tbs.StoreID = tbo.StoreID
         left join tblOrderStatus tos with (nolock) on tbo.OrderStatus = tos.OrderStatusID
where tbo.createDate >= getdate() - 5
  and tbo.OrderDate <= getdate() - 90
  and tbo.OrderStatus not in (16, 32)
  and ts.sorter_group_id is NULL
  and tbs.StoreID in (300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317,
                      318, 319, 320,
                      321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338,
                      339, 340, 341,
                      342, 343, 344, 345, 346, 347, 348)','【DRP-监控】创建时间最近但是订单很早之前下单的订单','stella.cui@gigacloudtech.com,bonnie.lin@gigacloudtech.com','liuchao@gigacloudtech.com,sujiawei@gigacloudtech.com,zhaijianfeng@gigacloudtech.com','销售订单号,店铺,订单状态,订单时间,创建时间','15 2,8,14,20 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
       tse.DisplayName,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and tbll.store_id in (302, 312, 308, 316)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus
union
select tse.DisplayName,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock)
                   on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tul.HISLINEID > 455348556
  and tse.StoreID in (302, 312, 308, 316)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tse.DisplayName, tul.orderId, tul.errmessage, toss.OrderStatus','【Noble监控】【重要】FedEx、UPS Buy Label 失败 - DRP','fzsales1@gigacloudtech.com','drp_us_it@gigacloudtech.com','From,OrderId,DealTime,WorkName,Info,OrderStatus','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>NH店铺</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
       tse.DisplayName,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and tbll.store_id in (301, 305, 304, 327)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus
union
select tse.DisplayName,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock)
                   on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tul.HISLINEID > 455348556
  and tse.StoreID in (301, 305, 304, 327)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tse.DisplayName, tul.orderId, tul.errmessage, toss.OrderStatus','【Noble监控】【重要】FedEx、UPS Buy Label 失败 - DRP','fzsales6@gigacloudtech.com','drp_us_it@gigacloudtech.com','From,OrderId,DealTime,WorkName,Info,OrderStatus','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>NH店铺</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
       tse.DisplayName,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and tbll.store_id in (319, 311, 321, 323, 318)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus
union
select tse.DisplayName,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock)
                   on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tul.HISLINEID > 455348556
  and tse.StoreID in (319, 311, 321, 323, 318)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tse.DisplayName, tul.orderId, tul.errmessage, toss.OrderStatus','【Noble监控】【重要】FedEx、UPS Buy Label 失败 - DRP','fzsales5@gigacloudtech.com','drp_us_it@gigacloudtech.com','From,OrderId,DealTime,WorkName,Info,OrderStatus','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>NH店铺</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
       tse.DisplayName,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and tbll.store_id in (331, 314, 313, 328)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus
union
select tse.DisplayName,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock)
                   on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tul.HISLINEID > 455348556
  and tse.StoreID in (331, 314, 313, 328)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tse.DisplayName, tul.orderId, tul.errmessage, toss.OrderStatus','【Noble监控】【重要】FedEx、UPS Buy Label 失败 - DRP','fzsales4@gigacloudtech.com','drp_us_it@gigacloudtech.com','From,OrderId,DealTime,WorkName,Info,OrderStatus','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>NH店铺</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
       tse.DisplayName,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and tbll.store_id in (309, 317, 320, 322, 329)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus
union
select tse.DisplayName,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock)
                   on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tul.HISLINEID > 455348556
  and tse.StoreID in (309, 317, 320, 322, 329)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tse.DisplayName, tul.orderId, tul.errmessage, toss.OrderStatus','【Noble监控】【重要】FedEx、UPS Buy Label 失败 - DRP','fzsales3@gigacloudtech.com','drp_us_it@gigacloudtech.com','From,OrderId,DealTime,WorkName,Info,OrderStatus','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>NH店铺</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select
       tse.DisplayName,
       tbll.sales_order_number,
       max(convert(varchar, tbll.create_time, 20)) AS dealTime,
       case
           when tbll.carrier_id = 3 then N''Buy Fedex Label''
           when tbll.carrier_id = 1 then N''Buy UPS Label''
           when tbll.carrier_id = 118 then N''Buy Amazon Label''
           else N''Buy Label'' end                   as workname,
       tbll.message                                as errmessage,
       toss.OrderStatus                            as orderStatus
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbs.ServiceLevel !=''UPS Roadie Ground''
  and tbll.store_id in (325, 324, 310, 307, 326)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and tbo.orderstatus not in (4, 16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus
union
select tse.DisplayName,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       ''Buy FedEx Label''                           AS workname,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join tuslogheader tld with (nolock) on tld.hisId = tul.hisId
         inner join dbo.tblorders tbo with (nolock)
                    on tld.STOREID = tbo.StoreID and tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblstoreexts tse with (nolock)
                    on tbo.StoreID = tse.StoreID
         inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock)
                   on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tul.worktype in (19)
  and tul.workstatus IN (0, 2, 4)
  and tul.HISLINEID > 455348556
  and tse.StoreID in (325, 324, 310, 307, 326)
  and DATEPART(hour, getdate()) in (23, 0, 1)
  and isnull(tbs.isInvoicePrinted, 0) <> 1
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
group by tse.DisplayName, tul.orderId, tul.errmessage, toss.OrderStatus','【Noble监控】【重要】FedEx、UPS、Amazon Buy Label 失败 - DRP','fzsales2@gigacloudtech.com','drp_us_it@gigacloudtech.com,yuebeibei@gigacloudtech.com,uswhcoordinator@gigacloudtech.com','From,OrderId,DealTime,WorkName,Info,OrderStatus','10 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>NH店铺</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('SELECT t.sales_order_number, t.sku
FROM (SELECT store_id, sales_order_number, toid.item_code + ''-001'' sku, SUM(toid.item_qty) AS intercept_qty
      FROM tbl_order_intercept toi with (nolock)
               inner join tbl_order_intercept_detail toid with (nolock) on toi.id = toid.intercept_id
      where toi.intercept_result = 1
        and toid.item_result = 1
        and isnull(toid.item_uuid,'''') != ''''
        and toi.create_date_time > DATEADD(HOUR, -6, GETDATE())
      GROUP BY store_id, sales_order_number, toid.item_code) AS i
         join
     (SELECT tt.StoreID store_id, tt.orderId sales_order_number, tt.sku, SUM(tt.qty) AS temp_qty
      FROM tblOrderTemps tt with (nolock)
      where isnull(tt.ItemStatus, 0) != 8
        and tt.CreationDate > DATEADD(HOUR, -6, GETDATE())
      GROUP BY tt.StoreID, tt.orderId, tt.sku) AS t
     ON t.store_id = i.store_id AND t.sales_order_number = i.sales_order_number AND t.sku = i.sku
         JOIN (SELECT tor.storeId store_id, tor.PayPalTxID sales_order_number, tod.ItemCode sku, SUM(qty) AS formal_qty
               FROM tblorders tor with (nolock)
                        inner join tblOrderDetails tod with (nolock)
                                   on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
               where tor.createDate > DATEADD(HOUR, -6, GETDATE())
               GROUP BY tor.storeId, tor.PayPalTxID, tod.ItemCode) AS f
              ON t.store_id = f.store_id AND t.sales_order_number = f.sales_order_number AND t.sku = f.sku
WHERE t.temp_qty <> f.formal_qty','【DRP监控】订单正式表与统一临时表明细数量不一致监控','liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com,liniannian@gigacloudtech.com','chenkailiang@gigacloudtech.com','销售订单号,Item Code','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select twe.warehouseCode,
       tse.DisplayName,
       tos.PayPalTxID,
       toss.OrderStatus,
       tod.ItemCode,
       tos.createDate
from tblOrders tos with (nolock)
         inner join tblOrderDetails tod with (nolock) on tos.StoreID = tod.StoreID
    and tos.OrderNumber = tod.OrderNumber
         inner join tblShipments tss with (nolock) on tss.ShipmentID = tod.ShipmentID
         inner join tblWarehouseExts twe with (nolock) on twe.warehouseId = tss.AssignedTo
         inner join tblOrderStatus toss with (nolock) on toss.OrderStatusID = tos.OrderStatus
         inner join tblstoreExts tse on tse.StoreID = tos.StoreID
where tss.Carrier = 184
group by twe.warehouseCode,
         tse.DisplayName,
         tos.PayPalTxID,
         toss.OrderStatus,
         tod.ItemCode,
         tos.createDate','【DRP监控】Purolator快递订单数据统计','yanglina@gigacloudtech.com,wuyating@gigacloudtech.com,xukunming@gigacloudtech.com,wang.xin@gigacloudtech.com','drp_us_it@gigacloudtech.com','仓库code,店铺名称,销售订单号,订单状态,Item Code,订单导入时间','0 0 * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''>美国仓库联络员</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>是</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select toi.sales_order_number,
       tor.OrderID,
       toi.create_date_time,
       case when toi.deal_type = 1 then N''取消'' else N''拦截'' end       as dealType,
       tos.OrderStatus,
       case when toi.feedback_status = 1 then N''成功'' else N''失败'' end as feedbackResult,
       toi.memo
from tbl_order_intercept toi with (nolock)
         left join tblorders tor with (nolock)
                   on toi.store_id = tor.StoreID and toi.sales_order_number = tor.PayPalTxID
         left join tblOrderStatus tos with (nolock) on tos.OrderStatusID = tor.OrderStatus
where toi.data_source = ''B2B''
  and toi.feedback_status = 2
  and toi.create_date_time > DATEADD(HOUR, -1, GETDATE())','【DRP监控】B2B取消/拦截接口返回失败','liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com','drp_us_it@gigacloudtech.com','销售订单号,系统订单号,申请取消/拦截时间,操作类型,订单状态,B2B返回结果,B2B返回失败的msg','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('SELECT t.sales_order_number, t.sku
FROM (SELECT store_id, sales_order_number, toid.item_code sku, SUM(toid.item_qty) AS intercept_qty
      FROM tbl_order_intercept toi with (nolock)
               inner join tbl_order_intercept_detail toid with (nolock) on toi.id = toid.intercept_id
      where toi.intercept_result = 1
        and toid.item_result = 1
        and isnull(toid.item_uuid,'''') = ''''
        and toi.create_date_time > DATEADD(HOUR, -4, GETDATE())
      GROUP BY store_id, sales_order_number, toid.item_code) AS i
         join
     (SELECT tt.StoreID                  store_id,
             tt.orderId                  sales_order_number,
             REPLACE(tt.sku, ''-001'', '''') sku,
             SUM(tt.qty) AS              temp_qty
      FROM tblOrderTemps tt with (nolock)
      where isnull(tt.ItemStatus, 0) != 8
        and tt.CreationDate > DATEADD(HOUR, -4, GETDATE())
      GROUP BY tt.StoreID, tt.orderId, tt.sku) AS t
     ON t.store_id = i.store_id AND t.sales_order_number = i.sales_order_number AND t.sku = i.sku
         JOIN (SELECT tor.storeId store_id,
                      tor.OrderID sales_order_number,
                      tor.sku,
                      SUM(qty) AS yzc_qty
               FROM tblYzcOrders tor with (nolock)
               where tor.createDate > DATEADD(HOUR, -4, GETDATE())
               GROUP BY tor.storeId, tor.OrderID, tor.sku) AS f
              ON t.store_id = f.store_id AND t.sales_order_number = f.sales_order_number AND t.sku = f.sku
WHERE t.temp_qty <> f.yzc_qty','【DRP监控】订单统一临时表与B2B临时表明细数量不一致监控','liuchao@gigacloudtech.com,chenkailiang@gigacloudtech.com,liniannian@gigacloudtech.com','chenkailiang@gigacloudtech.com','销售订单号,Item Code','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('SELECT IIF(tse.shipping_fee_type = ''pick_up_account_buy_fee'' OR tse.shipping_fee_type = ''pick_up_buyer_upload_fee'',
           N''上门取货'', N''一件代发'') AS ''订单类型'',
       ''UPS''                         AS ''物流公司'',
       ''UPS Roadie Ground''           AS ''物流服务'',
       twe.warehousecode             AS ''仓库'',
       COUNT(ts.shipmentid)          AS ''发货单量总数''
FROM dbo.tblshipments ts
         INNER JOIN tbl_common_shipping_file tc WITH (NOLOCK) ON tc.shipment_id = ts.shipmentid
         INNER JOIN dbo.tblstoreexts tse WITH (NOLOCK)
                    ON ts.storeid = tse.storeid
         INNER JOIN dbo.tblwarehouseexts twe WITH (NOLOCK)
                    ON twe.warehouseid = ts.assignedto
WHERE ts.servicelevel = ''UPS Roadie Ground''
  AND tc.create_date_time >= DATEADD(HOUR, -24,
                                     DATETIMEFROMPARTS(
                                             YEAR(GETDATE()),
                                             MONTH(GETDATE()),
                                             DAY(GETDATE()),
                                             15, 0, 0, 0))
  AND tc.create_date_time < DATETIMEFROMPARTS(
        YEAR(GETDATE()),
        MONTH(GETDATE()),
        DAY(GETDATE()),
        15, 0, 0, 0)
GROUP BY IIF(tse.shipping_fee_type = ''pick_up_account_buy_fee'' OR tse.shipping_fee_type = ''pick_up_buyer_upload_fee'',
             N''上门取货'', N''一件代发''), twe.warehousecode','【US_DRP】24小时内Roadie买单成功的发货单量统计','wuyating@gigacloudtech.com,wang.xin@gigacloudtech.com','chenkailiang@gigacloudtech.com,aojieying@gigacloudtech.com,chenhuizhu@gigacloudtech.com,xiafei@gigacloudtech.com,chen-lin@gigacloudtech.com,melissal@gigacloudtech.com,wangyan_2@gigacloudtech.com,yuebeibei@gigacloudtech.com,yuanwen@gigacloudtech.com,zhanghanlin@gigacloudtech.com,lunjia.li@gigacloudtech.com,xuyifan@gigacloudtech.com','类型,物流公司,物流服务,仓库,发货单量总数','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,monitor_cc,monitor_table_field,cron,monitor_text_template,send_type) VALUES ('select tbo.from_system,
       tul.orderId,
       max(convert(varchar, tul.creationdate, 20)) AS dealTime,
       tul.errmessage,
       toss.OrderStatus
from dbo.tuslogline tul with (nolock)
         inner join dbo.tblorders tbo with (nolock)
                    on tul.orderId = tbo.PayPalTxID
                        and tbo.orderstatus not in (4, 16, 32)
         inner join dbo.tblOrderDetails tod with (nolock)
                    on tbo.OrderNumber = tod.OrderNumber
                        and tbo.StoreID = tod.StoreID
         inner join dbo.tblShipments ts with (nolock)
                    on tod.ShipmentID = ts.ShipmentID
                        and ts.printedOn is null and ts.servicelevel =''UPS Roadie Ground''
                  inner join dbo.tblOrderStatus toss with (nolock)
                    on tbo.OrderStatus = toss.OrderStatusID
where tul.worktype in (44)
  and tul.workstatus IN (0, 2, 4)
and tul.hislineid >208773619
group by tbo.from_system, tul.orderId, tul.errmessage, toss.OrderStatus
ORDER BY max(convert(varchar, tul.creationdate, 20))','【US_DRP】UPS Roadie Buy Label 失败','wuyating@gigacloudtech.com,wang.xin@gigacloudtech.com,lishuai02@gigacloudtech.com,yanglina@gigacloudtech.com','chenkailiang@gigacloudtech.com,aojieying@gigacloudtech.com,chenhuizhu@gigacloudtech.com,xiafei@gigacloudtech.com,chen-lin@gigacloudtech.com,melissal@gigacloudtech.com,wangyan_2@gigacloudtech.com,yuebeibei@gigacloudtech.com,yuanwen@gigacloudtech.com,zhanghanlin@gigacloudtech.com,lunjia.li@gigacloudtech.com,xuyifan@gigacloudtech.com','From,OrderId,Last Buy Label Time,Error Message,OrderStatus','0 * * * *','<table border=''1'' cellpadding=''1'' cellspacing=''0'' align=''center''>
    <tr>
        <th>负责人</th>
        <th>用途</th>
        <th>是否需要处理</th>
        <th>是否需要回复</th>
    </tr>
    <tr>
        <td>
            <font size=''2'' style=''text-align: center;''></font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>监控</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
        <td>
            <font size=''2'' style=''text-align: center;''>否</font>
        </td>
    </tr>
</table><br /><br /><br />
{splicingTableStr}','email')
