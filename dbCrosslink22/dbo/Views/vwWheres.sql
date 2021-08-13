

CREATE view [dbo].[vwWheres]
as 
    select
        resp.req_num
    ,   resp.delivered
    ,   req.pssn
    ,   req.filingStatus
    ,   resp.respDate
    ,   resp.respCode
    ,   resp.refundDate
    ,   resp.respXml
    from
        dbo.tblRefundStatusResponse resp join dbo.tblRefundStatusRequest req on resp.reqId = req.reqId



