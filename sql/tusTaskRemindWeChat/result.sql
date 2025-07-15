INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('SELECT DISTINCT tul.orderId + '':'' + ''['' +
                case when tul.WORKTYPE = 19 then ''FEDEX'' when tul.WORKTYPE = 144 then ''AmazonLabel'' else ''UPS'' end +
                '']'' + N''['' + CASE
                                 WHEN tul.ERRMESSAGE LIKE ''%Length, width, and height must be greater than 0%''
                                     THEN ISNULL(tul.itemCode, '''') + N''长宽高为0''
                                 WHEN tul.ERRMESSAGE LIKE ''%Not Fedex Ground Or HomeDelivery%''
                                     THEN N''无法购买Ground服务''
                                 WHEN tul.ERRMESSAGE LIKE ''%Connection refused: connect%''
                                     THEN N''服务器拒绝请求，等待再次重试''
                                 WHEN
                                     tul.ERRMESSAGE LIKE
                                     ''%STANDARD_OVERNIGHT is not supported for the destination%''
                                     THEN N''STANDARD_OVERNIGHT is not supported for the destination''
                                 WHEN tul.ERRMESSAGE LIKE ''%Postal Code not found %''
                                     THEN N''城市邮编不匹配 ''
                                 ELSE tul.ERRMESSAGE
                    END + '']''
from tuslogheader tuh WITH (nolock)
         inner join tuslogline tul WITH (nolock) ON tuh.hisId = tul.hisId
         inner join tblOrders tbo WITH (nolock) on tbo.PayPalTxID = tul.ORDERID
         left join tblShipments tbs with (nolock) on tbs.StoreID = tbo.StoreID and tbs.OrderNumber = tbo.OrderNumber
where tuh.WORKTYPE IN (19)
  and tul.HISLINEID > 455348556
  and tul.WORKSTATUS in (2, 4)
  and tbo.OrderStatus not in (16, 32)
  and tul.ERRMESSAGE not like N''message:The service is currently unavailable%''
  and isnull(tbs.isInvoicePrinted, 0) <> 1
union
select DISTINCT tbll.sales_order_number + '':'' + ''['' +
                case when tbll.carrier_id = 3 then ''FEDEX'' when tbll.carrier_id = 118 then ''AmazonLabel'' else ''UPS'' end +
                '']'' + N''['' + CASE
                                 WHEN tbll.message LIKE ''%Not Fedex Ground Or HomeDelivery%''
                                     THEN N''无法购买Ground服务''
                                 WHEN tbll.message LIKE ''%Connection refused: connect%''
                                     THEN N''服务器拒绝请求，等待再次重试''
                                 WHEN
                                     tbll.message LIKE
                                     ''%STANDARD_OVERNIGHT is not supported for the destination%''
                                     THEN N''STANDARD_OVERNIGHT is not supported for the destination''
                                 WHEN tbll.message LIKE ''%Postal Code not found %''
                                     THEN N''城市邮编不匹配 ''
                                 ELSE tbll.message
                    END + '']''
from tbl_buy_label_log tbll with (nolock)
         left join tblOrders tbo with (nolock) on tbll.sales_order_uuid = tbo.sales_order_uuid
         left join tblOrderDetails tod with (nolock)
                   on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
         left join tblstoreExts tse with (nolock) on tbll.store_id = tse.StoreID
         left join tblOrderStatus toss with (nolock) on tbo.OrderStatus = toss.OrderStatusID
         left join tblShipments tbs with (nolock) on tbo.StoreID = tbs.StoreID and tbo.OrderNumber = tbs.OrderNumber
where tbll.tracking_number is null
  and tbs.PrintedOn is null
  and tbo.OrderStatus not in (16, 32)
group by tbll.sales_order_number, tbll.carrier_id, tbll.message, tod.ItemCode, tse.StoreID, tse.DisplayName,
         toss.OrderStatus','【监测】【重要】label购买失败','xiafei,LiuChao,SongYingHui,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','【监测】【重要】label购买失败<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select N''newOrder订单总数 -> '' + CONVERT(VARCHAR(4), count(*))
from tblOrders tos with (nolock)
where tos.OrderStatus = 1
  and tos.StoreID = 48
  and tos.OrderDate > ''2023-05-01''
  and tos.createDate < getdate() - 0.1
group by StoreID
union
select N''近4天newOrder数 -> '' + CONVERT(VARCHAR(4), count(*))
from tblOrders tos with (nolock)
where tos.OrderStatus = 1
  and tos.StoreID = 48
  and tos.OrderDate > getdate() - 4
  and tos.createDate < getdate() - 0.1
group by StoreID','Wayfair一号店neworder订单数','LiuChao,ZhaoYiFan,xiafei,WuPanZhi,songyinghui,sujiawei,zhaijianfeng','1 5,17 * * *','Wayfair一号店neworder订单数<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select orderId
from (select m.StoreID, m.DisplayName, m.orderId, m.CalTotal, sum(m.subTotal) as res
      from (SELECT tor.storeid,
                   tse.DisplayName,
                   tor.orderstatus,
                   tor.OrderTotal,
                   tor.TaxAmount,
                   tor.DiscountAmount,
                   tor.ShipAmount,
                   ISNULL(ISNULL(tod.ExternalComboItem, tod.sourceComboItem), tod.ItemCode)          as ItemCode,
                   tor.OrderTotal - tor.TaxAmount + tor.DiscountAmount - case tse.StoreType
                                                                             when ''fba'' then 0
                                                                             else tor.ShipAmount end as CalTotal,
                   case tor.storeid
                       when 208 then tod.UnitPrice
                       else
                           sum(tod.AdjQty * tod.UnitPrice) end                                       as subTotal,
                   tor.PayPalTxID                                                                    as orderId
            FROM tblorders tor with (nolock)
                     INNER JOIN tblorderDetails tod with (nolock)
                                on tod.storeid = tor.storeid and tod.orderNumber = tor.orderNumber
                     INNER JOIN tblstoreExts tse with (nolock) on tse.storeId = tor.storeId
            where tor.OrderStatus not in (16,32)
              and (tor.storeid not in (120, 226, 205, 212, 250, 260, 270, 280, 276, 277,888)
                or tor.buyerid in (1817,4173,6841))

              and tse.data_push_system != ''OHUB''

              and ISNULL(tse.noble_mark, 0) <> 1
              and tor.createDate > getdate() - 3
              and tod.ItemStatus <> 8
              and tor.OrderTotal > 10
              and isnull(tod.UnitPrice, 0) >= 0.5
            GROUP by tor.storeId, tor.OrderNumber, tor.OrderTotal, tod.UnitPrice,
                     tor.TaxAmount,
                     tor.DiscountAmount,
                     tor.ShipAmount,
                     tse.StoreType,
                     tor.PayPalTxID,
                     tor.orderstatus,
                     ISNULL(ISNULL(tod.ExternalComboItem, tod.sourceComboItem), tod.ItemCode),
                     tse.DisplayName
            having (tor.OrderTotal - tor.TaxAmount + tor.DiscountAmount - tor.ShipAmount) <>
                   sum(tod.AdjQty * tod.UnitPrice)
               --order by storeId, PayPalTxID
           ) m
      group by m.StoreID, m.DisplayName, m.CalTotal, m.orderId
      having (m.CalTotal <> sum(m.subTotal))) t','【重要】订单金额不一致监控','xiafei,LiuChao,LiZhenBiao,sujiawei,zhaijianfeng,chenkailiang','28 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','【重要】订单金额不一致监控<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select   N''B2B DropShip Pdf And BOL下载 -> ''+ CONVERT(VARCHAR(4),count(*) )
                   from
                   (select
                   tblo.paypaltxid,
                   yzc.url,
                   yzc.CutType,
                   tblo.createDate,
                   tbls.shipmentid,
                   tbls.CreationDate,
                   tbwe.warehouseCode
                   from tblShipments tbls with(nolock)
                   join tblOrders tblo with(nolock)  on tbls.storeid=tblo.storeid and tbls.ordernumber=tblo.ordernumber
                   join tblOrderDetails tbld with(nolock) on tblo.storeid=tbld.storeid and tblo.ordernumber=tbld.ordernumber and tbls.shipmentid=tbld.shipmentid
                   join tblWarehouseExts tbwe with(nolock) on tbls.AssignedTo=tbwe.warehouseId
                   left join tblYzcOrders yzc with(nolock) on yzc.orderid=tblo.PayPalTxID and yzc.LineItemNumber = tbld.ItemNumber
                   where 1=1
                   and tblo.orderstatus =''2''
                   and tbld.itemstatus in(''1'')
                   and tbls.Status in(''1'')
                   and tbwe.warehouseType=''OSW''
                   and tbwe.warehouseCode!=''CAL1''
                   and tblo.StoreID in(205,212,276,277)
                   and yzc.url is not null
                   and not exists (select * from tblDropshipLabel tdl with(nolock) where tdl.shipmentid=tbls.shipmentid)
                   and not exists (select * from tbl_extra_shipping_file tesf with(nolock) where tesf.shipment_id=tbls.shipmentid)
                   and not exists (select * from tbl_common_shipping_file tcsf with(nolock) where tcsf.shipment_id=tbls.shipmentid)
                   and tbls.isInvoicePrinted = 0
                   and tbls.CreationDate > getdate() - 3
                   ) tt','DownLoad DropShip Pdf And BOL From B2B监控','xiafei,LiuChao,songyinghui,shenzhenxing,sujiawei,zhaijianfeng','33 1,2,3 * * *','DownLoad DropShip Pdf And BOL From B2B监控<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select tos.PayPalTxID + ''_'' + replace(tod.ItemCode, ''-001'', '''') + ''_'' +
       case when isnull(att.carrier_code, '''') = '''' then ''(no carrier)'' else att.carrier_code end + ''_'' +
       case when isnull(carrier_service_level_code, '''') = '''' then ''(no service)'' else att.carrier_service_level_code end +
       ''_'' + toss.OrderStatus
from tblorders tos with (nolock)
         join tblOrderDetails tOD with (nolock) on tos.StoreID = tOD.StoreID and tos.OrderNumber = tOD.OrderNumber
         left join tbl_item_code_attachment att with (nolock)
                   on att.sales_order_number = tos.PayPalTxID and tod.ItemNumber = att.line_item_number
         left join tblShipments tS with (nolock) on tOD.ShipmentID = tS.ShipmentID
         join tblOrderStatus toss on toss.OrderStatusID = tos.OrderStatus
where tos.StoreID in (250, 260, 270, 280)
  and tos.OrderStatus in (1, 2, 4)
  and ts.ShipmentID is null
  and tod.ItemStatus <> 8
  and tos.createDate > getdate() - 3;','BOB店铺订单没有发货单','xiafei,liuchao,songyinghui,sujiawei,zhaijianfeng','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','BOB店铺订单没有发货单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct PayPalTxID from tblorders tor with (nolock)
  inner join tblOrderDetails tod with (nolock) on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
left join tblShipments tss with(nolock) on tod.ShipmentID = tss.ShipmentID
where tss.ShipmentID is null and tor.OrderStatus = 2 and tor.createDate >= getdate() -3 and tor.createDate < getdate()-0.1','有明细未生成发货单监控','xiafei,LiuChao,songyinghui,sujiawei,zhaijianfeng,chenkailiang','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','有明细未生成发货单监控<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct tor.PayPalTxID
from TblCloudWarehouseOrders TCWO with (nolock)
       inner join tblOrders tor with (nolock) on TCWO.OrderID = tor.PayPalTxID
where tor.OrderStatus not in (16, 32)
  and TCWO.CreationDate < getdate()-7
  and not exists(select 1
                 from TblCloudWarehouseLabel tcc with (nolock)
                 where tcc.OrderID = TCWO.OrderID
                   and tcc.BatchCode = TCWO.BatchCode)','云送仓订单超过7天未上传label','xiafei,LiuChao,sujiawei,zhaijianfeng','0 20 * * *','云送仓订单超过7天未上传label<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select id as taskId from tblSyncTask  with (nolock) where errMsg =''Time out'' and PostValue not in (''{"id":"12","authKey":"f66dd6c0-494d-11e9-a242-0235d2b38928"}'') and CreateTime >= ''2022-04-08''
                   order by CreateTime DESC','同步文件超时未执行','xiafei,LiuChao,sujiawei,zhaijianfeng','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','同步文件超时未执行<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('SELECT distinct der.[blocking_session_id]
                   FROM sys.[dm_exec_requests] AS der
                   INNER JOIN master.dbo.sysprocesses AS sp ON der.session_id = sp.spid
                   CROSS APPLY sys.[dm_exec_sql_text](der.[sql_handle]) AS dest
                   WHERE [blocking_session_id]>0 and wait_time >60000','数据库死锁监控','xiafei,LiuChao,sujiawei,zhaijianfeng,chenkailiang','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','数据库死锁监控<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct tor.paypaltxid as "销售订单号" from tblorders tor with(nolock)
                   inner join tblOrderDetails tOD with(nolock) on tor.StoreID = tOD.StoreID and tor.OrderNumber = tOD.OrderNumber
                   inner join tblshipments tss with(nolock) on tss.ShipmentID = toD.ShipmentID
                   where tor.OrderStatus not in (16,32)and tss.AssignedTo in (78,80,94,92,90) and tor.storeId in (205,212,276,277) and Carrier = 7','易仓上门取货卡车订单监控
','ShenLing,LiuChao,ChenHuiZhu,ShiShanShan,sujiawei,zhaijianfeng','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','易仓上门取货卡车订单监控
<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('SELECT ''storeId:'' + CONVERT(varchar(50), ttat.store_id) + ''||StoreName:'' +
       ts.StoreName + ''||orderNumber:'' +
       CONVERT(varchar(50), ttat.order_number) + ''||buyerCode:'' +
       CONVERT(varchar(50), ttat.buyer_code) + ''||oldWarehouse:'' +
       ttat.change_from + ''||newWarehouse:'' +
       ttat.change_to
FROM tbl_order_transaction_audit_trail ttat WITH (NOLOCK)
         LEFT JOIN tblstores ts WITH (NOLOCK) ON ttat.store_id = ts.StoreID
WHERE DATEDIFF(MINUTE, created_date_time, GETDATE()) <= 60
  AND ttat.store_id = 182
  AND operation_type = 28','WM店铺手动换仓企业微信提醒','LiuChao,gaoxuewen,wangjie,sujiawei,zhaijianfeng','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','WM店铺手动换仓企业微信提醒<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct PayPalTxID from dbo.tblorders tor with (nolock)
                                                       inner join dbo.tblOrderDetails tod with (nolock) on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber and tod.ItemStatus <> 8
                                                       left join dbo.tblShipments tss with(nolock) on tod.ShipmentID = tss.ShipmentID
                   where tor.storeid = 182 and tss.ShipmentID is null and tor.OrderStatus = 1','Walmart分单失败监控','LiuTingTing,WangJie,GaoXueWen,LiuChao,sujiawei,zhaijianfeng','0 0,17 * * *','Walmart分单失败监控<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct PayPalTxID from tblOrders tor with(nolock)
                   inner join tblOrderDetails tOD on tor.StoreID = tOD.StoreID and tor.OrderNumber = tOD.OrderNumber
                   where tOD.sellerId = 694 and createDate > ''2022-01-26''','B2B疑似服务店铺（seller id=694）的订单','xiafei,LiuChao,SongYingHui,sujiawei,zhaijianfeng','0 17 * * *','B2B疑似服务店铺（seller id=694）的订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct OrderID
from tblOrderTemps  tot with (nolock)
where IsExported = 0
  and StockOut in (1, 10, 11, 12)
  and not exists(select 1
                 from tblOrderTemps tot1 with (nolock)
                 where tot.StoreID = tot1.StoreID
                   and tot.OrderID = tot1.OrderID
                   and tot1.ItemCode is null)
  and ItemCode is not null
  and CreationDate < getdate() - 0.2','疑似未收到采购结果订单','xiafei,LiuChao,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','疑似未收到采购结果订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select tor.PayPalTxID
                   from tblorders tor with(nolock)
                            left join tbl_common_shipping_file tcsf with(nolock) on tor.PayPalTxID = tcsf.sales_order_number
                   where tor.StoreID = 260 and tcsf.sales_order_number is null and tor.OrderStatus <>16
                   order by createDate DESC','260店铺未buy label的订单','xiafei,LiuChao,sujiawei,zhaijianfeng','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','260店铺未buy label的订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct temp.PayPalTxID
                                                         from (select distinct tor.PayPalTxID, tss.AssignedTo
                                                               from tblorders tor with (nolock)
                                                                        inner join tblOrderDetails tod with (nolock)
                                                                                   on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                                                                        inner join tblShipments tss with (nolock) on tod.ShipmentID = tss.ShipmentID
                                                               where 1 = 1
                                                                 and tor.createDate > getdate() -7
                                                                 and tor.OrderStatus in (2, 4)
                                                                 and tss.AssignedTo = 66
                                                                 and tss.Carrier = 7
                                                                 and tor.StoreID in (205, 212,276,277)) temp
                                                                  join tblYzcOrders yzc with (nolock) on temp.PayPalTxID = yzc.OrderID
                                                         where isnull(yzc.Warehouse, '''') <> ''CAL1''
                                                           and not exists(select 1
                                                                          from tbl_extra_shipping_file tesf with (nolock)
                                                                          where tesf.sales_order_number = temp.PayPalTxID)','ACME指定仓库错误','xiafei,LiuChao,SongYingHui,sujiawei,zhaijianfeng','0 1,17 * * *','ACME指定仓库错误<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct tor.PayPalTxID
                   from tblorders tor with (nolock)
                            inner join tblOrderDetails tod with (nolock) on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                            inner join tblShipments tss with (nolock) on tod.StoreID = tss.ShipmentID
                            inner join tbl_hold_inventory thi with (nolock)
                                       on thi.item_code + ''-001'' = tod.ItemCode and thi.create_date_time > getdate() - 1 and
                                          tss.CreationDate > thi.create_date_time
                   where tor.createDate > ''2023-01-01''
                     and tor.OrderStatus in (2, 4)','疑是冻结库存后超分','xiafei,LiuChao,ChenGuangKuo,SongYingHui,ZhangYuMeng,sujiawei,zhaijianfeng','0 1,17 * * *','疑是冻结库存后超分<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct temp.PayPalTxID
                                      from (select distinct tor.PayPalTxID, twe.warehouseCode
                                            from tblorders tor with (nolock)
                                                     inner join tblOrderDetails tod with (nolock)
                                                                on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
                                                     inner join tblShipments tss with (nolock) on tod.ShipmentID = tss.ShipmentID
                                                     inner join tblWarehouseExts twe with (nolock) on tss.AssignedTo = twe.warehouseId
                                            where 1 = 1
                                              and tor.createDate > ''2024-01-01''
                                              and tor.BuyerId = ''2017''
                                              and tor.OrderStatus in (2, 4)
                                              and tss.Carrier = 7
                                              and tor.StoreID in (205, 212,276)) temp
                                               join tblYzcOrders yzc with (nolock) on temp.PayPalTxID = yzc.OrderID
                                      where isnull(yzc.Warehouse, '''') <> temp.warehouseCode
                                        and not exists(select 1
                                                       from tbl_extra_shipping_file tesf with (nolock)
                                                       where tesf.sales_order_number = temp.PayPalTxID)','王庆卡车订单发货仓库和指定仓库不一致，需手动上传bol文件','xiafei,LiuChao,SongYingHui,WangQing,sujiawei,zhaijianfeng','0 1,17 * * *','王庆卡车订单发货仓库和指定仓库不一致，需手动上传bol文件<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct temp.PayPalTxID
                                      from (select distinct tor.PayPalTxID
                                            from tblorders tor with (nolock)
                                            where 1 = 1
                                              and tor.createDate > ''2024-01-01''
                                              and tor.BuyerId = ''2017''
                                              and tor.OrderStatus not in (16, 32)
                                              and tor.StoreID in (205, 212,276)) temp
                                               join tblYzcOrders yzc with (nolock) on temp.PayPalTxID = yzc.OrderID
                                      where isnull(yzc.url, '''') =''''','王庆B2B MF417订单，缺少运输单，buyer需要取消原订单，重新导单','xiafei,LiuChao,SongYingHui,WangQing,sujiawei,zhaijianfeng','0 1,17 * * *','王庆B2B MF417订单，缺少运输单，buyer需要取消原订单，重新导单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select top 100 sales_order_number
                   from tbl_common_shipping_file with (nolock)
                   where 1 = 1
                     and merge_id is null
                     and store_id in (205, 212, 276, 277)
                     and shipping_label_type = ''PDF''
                     and shipping_file_from = ''FROM_B2B''
                     and shipping_label_path not like ''%/processed%''
                   order by create_date_time DESC','疑是存在无效label影响仓库合并','xiafei,LiuChao,LiZhenBiao,sujiawei,zhaijianfeng','0 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','疑是存在无效label影响仓库合并<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct tot.orderID
from tblOrderTemps tot with (nolock)
         inner join dap_order_owner doo with (nolock) on tot.orderID = doo.order_id
where tot.IsExported = 0
  and tot.StockOut = 0
  and tot.CreationDate > getdate() - 30
  and isnull(doo.create_date_time, getdate() - 1) < getdate() - 0.1','采购完成未导单订单','xiafei,LiuChao,LiZhenBiao,SongYingHui,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','采购完成未导单订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select top 10 id as taskid from tblSyncTask with(nolock)  where PostValue = ''Release StockLock Order'' and CreateTime > getdate() - 1 and CreateTime < getdate() -0.05 and STATUS in (0,1) order by CreateTime DESC','疑似自动购买未及时解析','xiafei,LiuChao,SongYingHui,sujiawei,zhaijianfeng','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','疑似自动购买未及时解析<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select sales_order_number
                                      from tbl_common_shipping_file tf with (nolock)
                                               join tblorders tor with (nolock) on tf.sales_order_number = tor.PayPalTxID
                                      where merge_id is null
                                        and exists(select 1 from tblShipments tss with (nolock) where tss.ShipmentID = tf.shipment_id )
                                        and tor.OrderStatus not in (16, 32)
                                        and not exists(select 1
                                                       from tblorders tor with (nolock)
                                                                join tblOrderDetails tOD with (nolock)
                                                                     on tor.StoreID = tOD.StoreID and tor.OrderNumber = tOD.OrderNumber
                                                                join tblShipments tS with (nolock) on tOD.ShipmentID = tS.ShipmentID
                                                       where tf.store_id = tor.StoreID
                                                         and tf.sales_order_number = tor.PayPalTxID
                                                         and tf.warehouse_id = ts.AssignedTo)','label与发货单仓库不一致','xiafei,LiuChao,SongYingHui,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','label与发货单仓库不一致<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select aa.countOrder from (
                   select count(1) countOrder from tblyzcorders with(nolock) where IsExported = 0 and CreateDate >getdate() -1 and CreateDate <getdate() -0.08
                   ) aa where aa.countOrder >0','B2B订单未及时导单数','xiafei,LiuChao,SongYingHui,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','B2B订单未及时导单数<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct N''订单号: '' + tblo.PayPalTxID + N''; 仓库:'' + twe.warehouseCode
                   from tblOrders tblo with (nolock)
                            join tblShipments tbls with (nolock) on tbls.StoreID = tblo.StoreID and tbls.OrderNumber = tblo.OrderNumber
                           join tblWarehouseExts twe with (nolock) on tbls.AssignedTo = twe.warehouseId
                   where tbls.AssignedTo in ( 140, 154, 156)
                     and tbls.Status in (1, 2, 4)
                     and tbls.CreationDate >= getdate() - 1','【DRP-监控】CAN3,CAN4,Lep1,Lep2仓库发货单提醒','LiuChao,sujiawei,zhaijianfeng','15 * * * *','【DRP-监控】CAN3,CAN4,Lep1,Lep2仓库发货单提醒<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select N''销定:'' + tbo.OrderID + N'',店铺:'' +tbse.DisplayName
                   from tblOrderTemps tbo with (nolock)
                            left join tblstoreExts tbse with (nolock) on tbo.StoreID = tbse.StoreID
                   where tbo.OrdersFrom != ''B2BReship''
                     and tbse.autobuy_check_warehouse in (3, 4)
                     and tbo.CreationDate > getdate() - 5
                     and drp_shipping_code is null','需要审核仓库的店铺订单,指定物流在DRP内无映射','LiuChao,shishuwen,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','需要审核仓库的店铺订单,指定物流在DRP内无映射<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct OrderID from tblAmazonOrdersForThirdParty with(nolock) where IsExported = 0 and createDate < getdate() -0.1','dajian店铺未及时导单订单','xiafei,LiuChao,SongYingHui,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','dajian店铺未及时导单订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select PayPalTxID from  tblorders  with(nolock) where createDate > getdate() - 3 and OrderStatus = 4 and BuyerId in (1817,4173,6841)','buerId为1817,4173,6841的订单','LiuChao,shishuwen,sujiawei,zhaijianfeng','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','buerId为1817,4173,6841的订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct tblo.PayPalTxID ''订单号''
                                      from tblShipments tbls with (nolock)
                                               join tblWarehouseExts tbwe with (nolock) on tbwe.warehouseId = tbls.AssignedTo
                                               join tblstoreExts tblst with (nolock) on tblst.StoreID = tbls.StoreID
                                               join tblOrders tblo with (nolock)
                                                    on tblo.StoreId = tbls.StoreId and tblo.orderNumber = tbls.orderNumber and tblo.OrderStatus = 2
                                               join tblOrderDetails tbld with (nolock) on tbld.StoreId = tbls.StoreId and tbld.orderNumber = tbls.orderNumber
                                          and tbld.shipmentId = tbls.shipmentId and tbld.ItemStatus = 1
                                      where tbwe.warehouseId in (80, 92, 98, 100, 108)
                                        and tbls.status = 1
                                        and tbls.CreationDate > getdate() - 90
                                        and tbls.CreationDate < getdate() - 0.5','NJX1,ATX4,CAX3,NJX2,CAX5订单未推送','LiuChao,shishuwen,sujiawei,zhaijianfeng','15 2,5,8,17,20 * * *','NJX1,ATX4,CAX3,NJX2,CAX5订单未推送<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select tbo.PayPalTxID from tblOrders tbo with(nolock) where tbo.StoreID = 325
and tbo.createDate > getdate()-1
and tbo.OrderStatus not in (32,16,4)','325店铺订单','LiuChao,sujiawei,zhaijianfeng','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','325店铺订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select tbo.PayPalTxID
                   from tblOrders tbo with (nolock)
                            left join tblOrderDetails tod with (nolock) on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber
                   where tbo.OrderStatus = 16
                     and tod.ShipmentID is not null
                     and tbo.createDate > getdate() -7','订单取消但是发货单并未删除','LiuChao,sujiawei,zhaijianfeng','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','订单取消但是发货单并未删除<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select N''销售订单号: '' + tbo.PayPalTxID
from tblOrders tbo with (nolock)
where tbo.StoreID = 256
  and tbo.OrderStatus = 2
  and not exists(select tesf.file_id
                 from tbl_extra_shipping_file tesf with (nolock)
                 where tesf.store_id = tbo.StoreID
                   and tesf.sales_order_number = tbo.PayPalTxID
                   and tesf.is_valid = 1)','buyerPickUp未收到bol文件','LiuChao,sujiawei,zhaijianfeng','15 23 * * *','buyerPickUp未收到bol文件<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select tcsf.sales_order_number
from tbl_common_shipping_file tcsf with (nolock)
         left join tblOrders tbo with (nolock) on tbo.StoreID = tcsf.store_id and tbo.OrderNumber = tcsf.order_number
where tcsf.shipping_file_from = ''DRP_OFFLINE_UPLOAD''
  and exists(select tcsf2.file_id
             from tbl_common_shipping_file tcsf2 with (nolock)
             where tcsf2.sales_order_number = tcsf.sales_order_number
               and tcsf2.shipping_file_from = ''FROM_B2B'')
  and tbo.OrderStatus not in (16, 32)
  and tcsf.create_date_time > getdate() - 7
  and tcsf.create_date_time < getdate() - 1','疑似手工上传和定时任务下载label并发的订单','LiuChao,sujiawei,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','疑似手工上传和定时任务下载label并发的订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select N''销订:'' + tbo.PayPalTxID + N'', 店铺:'' + cast(tbo.StoreID as varchar) + N'', 订单状态:'' +
       cast(tbo.OrderStatus as varchar) + N'', 订单时间:'' +
       FORMAT(tbo.OrderDate, ''yyyy-MM-dd HH:mm:ss'') + N'', 导入时间:'' + FORMAT(tbo.createDate, ''yyyy-MM-dd HH:mm:ss'')
from tblorders tbo with (nolock)
         left join tblShipments ts with (nolock) on tbo.StoreID = ts.StoreID and tbo.OrderNumber = ts.OrderNumber
where tbo.createDate >= getdate() - 5
  and tbo.OrderDate <= getdate() - 90
  and tbo.OrderStatus not in (16, 32)
  and ts.sorter_group_id is NULL','创建时间最近但是订单很早之前下单的订单','LiuChao,sujiawei,zhaijianfeng','15 2,8,20 * * *','创建时间最近但是订单很早之前下单的订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct N''订单号: '' + toi.sales_order_number + N'' 店铺名称: '' + te.DisplayName
from tbl_order_intercept toi with (nolock)
         left join tbl_item_code_attachment tica with (nolock) on toi.store_id = tica.store_id
    and toi.sales_order_number = tica.sales_order_number
         left join tblstoreExts te with (nolock) on te.StoreID = toi.store_id
where toi.intercept_result = 1
  and toi.create_date_time > GETDATE() - 1
  and toi.store_id = 402
  and tica.attachment_type = ''shipping_label_file''
  and source_carrier not in (''FEDEX'', ''UPS'')','小众物流（非UPS和FedEx）取消成功的情况','LiuChao,sujiawei,zhaijianfeng,wanyuanqi,xiafei,LiZhenBiao,ChenHuiZhu','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','小众物流（非UPS和FedEx）取消成功的情况<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct N''销售订单号: '' + tblo.PayPalTxID + N'', 店铺名称:'' + te.DisplayName
from tblOrders tblo with (nolock)
         join tblShipments tbls with (nolock) on tbls.StoreID = tblo.StoreID and tbls.OrderNumber = tblo.OrderNumber
         join tblstoreExts te with (nolock) on tblo.StoreID = te.StoreID
where tbls.AssignedTo in (133)
  and tblo.OrderStatus <> 16
  and tbls.Status in (1)','分单到CANH4仓库的订单','LiuChao,sujiawei,zhaijianfeng,yuebeibei,xiafei,LiZhenBiao,ChenHuiZhu','15 2,4,6,8,10,18,20,22,0 * * *','分单到CANH4仓库的订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select twe.warehouseCode + '':'' + convert(varchar(10), max(created_date_time), 120)
from tbl_wms_pick_zone_inventory wpi
         inner join tblWarehouseExts twe on twe.warehouseId = wpi.warehouse_id
where wpi.created_date_time < convert(varchar(10), GETDATE(), 120)
and wpi.created_date_time > GETDATE() -7
group by twe.warehouseCode','WMS库存及库位数据未及时同步到DRP','chenkailiang,lizhenbiao,liuchao','15 2,3,4 * * *','WMS库存及库位数据未及时同步到DRP<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select shipment_id
from tbl_common_shipping_file with (nolock )
where create_date_time > ''2024-04-15''
group by shipment_id
having count(shipment_id) > 1','买label并发的发货单','LiuChao,sujiawei,zhaijianfeng','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','买label并发的发货单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select DISTINCT N''店铺:'' + cast(tbo.StoreID as varchar(50)) + N'', 销售订单号:'' + tbo.PayPalTxID + N'', 进系统时间:'' +
               FORMAT(tbo.createDate, ''yyyy-MM-dd HH:mm:ss'')
from tblOrders tbo with (nolock)
         left join tblOrderDetails tod with (nolock) on tbo.StoreID = tod.StoreID and tbo.OrderNumber = tod.OrderNumber
         left join tblShipments tbs with (nolock) on tod.ShipmentID = tbs.ShipmentID
where tbo.OrderStatus = 2
  and tbs.Status not in (2, 4)
  and tbs.shipping_ready_date < getdate() - 3','超3天未发货订单','LiuChao,sujiawei,zhaijianfeng,chenkailiang','15 4,8,20,0 * * *','超3天未发货订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select distinct N''销售订单号: '' + OrderID
from tblOrderTemps with(nolock)
where CreationDate > getdate() - 1
  and sku_mapping_json like ''%true%''','一对多映射的订单','LiuChao,sujiawei,zhaijianfeng,liniannian,chenkailiang','15 4,8,20,0 * * *','一对多映射的订单<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select sales_order_number as salesOrderNumber
from tbl_order_intercept toi with (nolock)
         join tblOrders tO2 with (nolock) on
    toi.sales_order_number = tO2.PayPalTxID and tO2.StoreID = toi.store_id
where tO2.OrderStatus != 16
  and toi.api_version = 2
  and toi.store_id <> 187
  and toi.data_source != ''DRP''
  and toi.deal_type = 1
  and toi.create_date_time between DATEADD(HOUR, -1,
                                           DATEADD(MINUTE, DATEDIFF(MINUTE, 0, GETDATE()) / 60 * 60, 0))
    and DATEADD(HOUR, DATEDIFF(HOUR, 0, GETDATE()), 0)
order by create_date_time desc;','部分取消订单监控','LiuChao,sujiawei,chenkailiang,zhaijianfeng,liniannian','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','部分取消订单监控<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select DISTINCT N''销售订单号: '' + tor.PayPalTxID
from tblOrders tor with (nolock)
         join tblOrderDetails tod with (nolock)
              on tor.StoreID = tod.StoreID and tor.OrderNumber = tod.OrderNumber
         join tblshipments tbls with (nolock) on tod.ShipmentID = tbls.ShipmentID
join tblWarehouseExts twe with (nolock) on twe.warehouseId = tbls.AssignedTo
where 1 = 1
  and twe.status = 0
  and tor.OrderStatus in (2)
  and tbls.Status = 1
  and tor.createDate >= ''2024-01-20''','订单分到已禁用仓库','LiuChao,sujiawei,zhaijianfeng,liniannian,chenkailiang','15 4,8,20,0 * * *','订单分到已禁用仓库<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select sales_order_number
from tbl_extra_shipping_orders tso with (nolock )
where tso.store_id = 430
  and not exists(select 1
                 from tbl_extra_shipping_file tf with (nolock )
                 where tf.store_id = 430
                   and tf.extra_file_type = ''pallet_label_file'')','3PL Dropship Truck-FBA订单缺少pallet文件','LiuChao,ChenKaiLiang,zhaijianfeng','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','3PL Dropship Truck-FBA订单缺少pallet文件<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('select tc1.sales_order_number
from tbl_extra_shipping_file tc1 with(nolock)
where tc1.store_id = 256
  and tc1.create_date_time > GETDATE() - 1
  and tc1.extra_file_type = ''bol_file''
  and not exists(select 1
                 from tbl_extra_shipping_file tc2 with(nolock)
                 where tc1.shipping_order_id = tc2.shipping_order_id
                   and tc2.extra_file_type = ''shipping_label_file'')','BuyerPickUp缺少shippingLabel','LiuChao,zhaijianfeng,liniannian,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','BuyerPickUp缺少shippingLabel<br>{splicingTableStr}','wechat','external_monitor')
INSERT INTO sys_monitor_config (monitor_table_sql,monitor_subject,monitor_to,cron,monitor_text_template,send_type,monitor_serve_name) VALUES ('SELECT tblmdb.id
FROM tbl_merge_download_batch tblmdb WITH (NOLOCK)
WHERE 1 = 1
  and tblmdb.push_wms in (0, 1, 2)
  and tblmdb.create_date_time > GETDATE() - 3','需要补推包裹表、拣货表数据的批次id数据','LiuChao,zhaijianfeng,chenkailiang','15 0,1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22,23 * * *','需要补推包裹表、拣货表数据的批次id数据<br>{splicingTableStr}','wechat','external_monitor')
