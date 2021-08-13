CREATE procedure up_processThirdPartyStatusReq
    @requestId                   int        = null
,   @finalStatusOverride        bit         = 0
as

declare @url            varchar(100)
declare @pData          varchar(max)
declare @fmtPost        varchar(max)
declare @rData          varchar(max)
declare @rXML           xml
declare @respCode       int
declare @errDesc        varchar(max)

declare @reqId          int
declare @pssn           varchar(9)
declare @fstatus        char(1)
declare @rAmount        varchar(25)
declare @pin            char(5)

declare @respId         int
    
    set nocount on

    set @url = 'https://sa.www4.irs.gov/icce/api/refundstatus/'

    declare curSdata cursor fast_forward for
        select
            rsr.reqId
        ,   replicate('0',9 - datalength(convert(varchar(9),rsr.pssn))) + convert(varchar(9),rsr.pssn) pssn
        ,   convert(char(1),rsr.filingStatus) filingStatus
        ,   convert(varchar(25),convert(int,rsr.refundAmount)) refundAmount
        ,   rsr.pin
        from
            dbo.tblRefundStatusRequest rsr
        where
            rsr.reqId = isnull(@requestId, rsr.reqId)  
            and rsr.finalStatus = @finalStatusOverride
        order by
            rsr.reqId


    open curSdata
    fetch next from curSdata into @reqId,@pssn,@fstatus,@rAmount, @pin

    while @@fetch_status = 0
        begin
            set @fmtPost = null
            set @rData = null
            set @respCode = null
            set @errDesc = null
            set @pData = 'ssn=' + @pssn + '|filingStatus=' + @fstatus + '|refundDollarAmount=' + @rAmount + '|pin=' + @pin + '|clientId=petzent-440337051|lang=en'


            print 'Begin Processing: ' + @pssn + ' ...'
            --print 'Raw Data: ' + @pData

            exec dbAdmin.dbo.up_postJson @url, @pData, @fmtPost output, @rData output, @respCode output, @errDesc output

            --print 'Formatted JSON Post Data: ' + @fmtPost
            --print 'Return Data: ' + @rData
            print 'Response Code: ' + convert(varchar(10),@respCode)

            if isnull(@errDesc,'') != ''
                print 'Error Description: ' + @errDesc

            set @rXML = @rData

            insert [dbo].[tblRefundStatusResponse](
                [reqId]
            ,   [pssn]
            ,   [respCode]
            ,   [return_status]
            ,   [refundDate]
            ,   [respXml]
            ,   [finalStatus]
            ,   [errMsg]
            )
                select
                    @reqId reqId
                ,   @pssn pssn
                ,   isnull(@respCode,0) respCode            
                ,   rs.rXML.value('(/refundStatus/status)[1]','varchar(100)') return_status
                ,   rs.rXML.value('(/refundStatus/refundDate)[1]','date') refundDate
                ,   @rXML respXml
                ,   isnull(rs.rXML.value('(/refundStatus/finalStatus)[1]','bit'),0) finalStatus
                ,   @errDesc [errMsg]
                from    
                    (select isnull(@rXML,'') rXML) rs     
      
                set @respId = scope_identity()

                print 'Inserted Response Id: ' + convert(varchar(25),@respId)

                if @respCode = 200
                    update req
                        set req.return_status = res.respXml.value('(/refundStatus/status)[1]','varchar(100)')
                    ,   req.statusDate = res.respDate
                    ,   req.refundDate = res.respXml.value('(/refundStatus/refundDate)[1]','date')
                    ,   req.finalStatus = isnull(res.respXml.value('(/refundStatus/finalStatus)[1]','bit'),0)
                    ,   req.respId = @respId
                    from
                        [dbo].[tblRefundStatusRequest] req join [dbo].[tblRefundStatusResponse] res on req.reqId = res.reqId
                            and res.respId = @respId

                /*
                select
                    rs.*
                ,   rs.rData.value('(/refundStatus/status)[1]','varchar(100)') ReturnStatus
                ,   rs.rData.value('(/refundStatus/refundDate)[1]','date') RefundDate
                ,   rs.rData.value('(/refundStatus/description)[1]','varchar(max)') [Description]
                ,   rs.rData.value('(/refundStatus/lonDescription)[1]','varchar(max)') LongDescription
                ,   rs.rData.value('(/refundStatus/contactInfo/details)[1]','varchar(max)') ContactInfo_Details
                ,   rs.rData.value('(/refundStatus/contactInfo/beforeYouCall)[1]','varchar(max)') ContactInfo_BeforeYouCall
                ,   rs.rData.value('(/refundStatus/contactInfo/refNumber)[1]','varchar(max)') ContactInfo_ReferenceNumber
                ,   rs.rData.value('(/refundStatus/contactInfo/hours)[1]','varchar(max)') ContactInfo_Hours
                ,   rs.rData.value('(/refundStatus/finalStatus)[1]','bit') FinalStatus
                from
                    @xmlReturnStatus rs
                */

            print 'End Processing: ' + @pssn + ' ...'

            fetch next from curSdata into @reqId,@pssn,@fstatus,@rAmount, @pin
        end

    close curSdata
    deallocate curSdata
