
CREATE VIEW [dbo].[vwBusinessOrders]
AS
SELECT     dbo.orders.account, dbo.orders.user_id AS UserID, dbo.orders.season, dbo.ord_items.prod_cd AS ProdCD, dbo.orders.ord_stat AS OrderStat
FROM         dbo.ord_items INNER JOIN
                      dbo.orders ON dbo.orders.ord_num = dbo.ord_items.ord_num
WHERE     (dbo.ord_items.prod_cd LIKE 'BUS%') AND (dbo.orders.ord_stat IN ('C', 'A'))


