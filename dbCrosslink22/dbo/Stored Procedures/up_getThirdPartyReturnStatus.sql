


CREATE procedure [dbo].[up_getThirdPartyReturnStatus] --338000293,1,5562,12345
    @pssn                   char(9)
,   @userId                 int
,   @filingStatus           tinyint         = null
,   @refundAmount           money           = null
,   @pin                    int             = null
as

declare @reqId int
declare @queuePos int

    set nocount on

    select 
        @reqId = req.reqId
    from
        dbo.tblRefundStatusRequest req
    where
        req.pssn = @pssn
        and req.userId = @userId


    if @reqId is null
        begin
            if @userId > 996000
                insert [dbo].[tblRefundStatusRequest](
                    [pssn]
                ,   [userId]
                ,   [filingStatus]
                ,   [refundAmount]
                ,   [pin]
                )
                    select 
                        replicate('0',9 - datalength(convert(varchar(9),a.pssn))) + convert(varchar(9),a.pssn) pssn
                    ,   a.UserId
                    ,   tm.FilingStat
                    ,   tm.IRSRefund
                    ,   tp.[xml].value('(/tblTaxpayer/txtPPIN)[1]','int') pin
                    from
                        (select @pssn pssn, @userId UserId) a left join Taxbrain16.dbo.tblTaxMaster tm on a.pssn = tm.PrimSSN
                            and tm.IRSAckCode = 'A'
                            and tm.IRSRefund > 0
                        left join Taxbrain16.dbo.tblTaxpayer tp on tm.ReturnID = tp.ReturnID
                            and tp.[xml].value('(/tblTaxpayer/txtPPIN)[1]','int') is not NULL    
/*
            else
                insert [dbo].[tblRefundStatusRequest](
                    [pssn]
                ,   [userId]
                ,   [filingStatus]
                ,   [refundAmount]
                ,   [pin]
                )                
                    
*/




            set @reqId = scope_identity()
        end
     
    
    select
        @queuePos = count(*)
    from
        dbo.tblRefundStatusRequest req
    where
        req.reqId <= @reqId
        and req.finalStatus = 0
        



    select
        req.reqId
    ,   req.respId 
    ,   req.reqDate
    ,   req.return_status
    ,   req.statusDate
    ,   req.refundDate
    ,   req.refundAmount
    ,   req.finalStatus
    ,   res.respXml
    ,   lres.respId last_respId
    ,   lres.respCode last_respCode
    ,   lres.errMsg last_errMsg
    ,   lres.respDate last_respDate
    ,   case 
            when req.finalStatus = 1 then null 
            when req.filingStatus is null or req.refundAmount is null or req.pin is null then null
            else @queuePos
        end QueuePosition
    from
        dbo.tblRefundStatusRequest req left join dbo.tblRefundStatusResponse res on req.reqId = res.reqId
            and req.respId = res.respId
        left join dbo.tblRefundStatusResponse lres on req.respId = lres.respId
    where
        req.reqId = @reqId

