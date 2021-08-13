CREATE procedure [dbo].[up_processThirdPartyStatusRequest] --'https://sa.www4.irs.gov/iccews/api/refundstatus/', 409296868
    @url            varchar(100)
,   @pssn           int                 = null    
as

declare @pData          varchar(max)
declare @fmtPost        varchar(max)
declare @rData          varchar(max)
declare @rXML           xml
declare @respCode       varchar(max)
declare @errDesc        varchar(max)

declare @reqId          int
declare @ssn            varchar(9)
declare @fstatus        char(1)
declare @rAmount        varchar(25)
declare @pin            char(5)

declare @respId         int

    set nocount on

    -- set @url = 'https://sa.www4.irs.gov/icce/api/refundstatus/'

    -- Update the requests with any missing information
    -- Taxbrain requests ...
    /*
    update rsr
        set rsr.filingStatus = tm.FilingStat
    ,   rsr.refundAmount = tm.IRSRefund
    --,   rsr.pin = p.PIN
    ,   rsr.pin = pd.[XML].value('(/tblPrepDesignee/txtThirdPartyPin)[1]', 'varchar(5)')
    from
        dbo.tblRefundStatusRequest rsr join dbo.tblTaxmast xtm on rsr.pssn = xtm.pssn
            and rsr.finalStatus = 0
            and rsr.userId > 996000
            and rsr.pssn = isnull(@pssn,rsr.pssn)
            --and rsr.userId = isnull(@userId, rsr.userId)
        join Taxbrain16.dbo.tblReturn r on xtm.rtn_id = r.ReturnID
            and r.ReturnDeleted is null
            and r.RefundStatusAgreement = 'X'
        join Taxbrain16.dbo.tblPrepDesignee pd on r.ReturnID = pd.ReturnId
        join Taxbrain16.dbo.tblPreparer p on pd.PreparerId = p.PreparerID
        join Taxbrain16.dbo.tblTaxMaster tm on rsr.pssn = tm.PrimSSN
            and tm.IRSAckCode = 'A'
            and tm.IRSRefund > 0
    */

    -- Crosslink requests




    declare curSdata cursor fast_forward for


        select top 4741
            rsr.reqId
        ,   replicate('0',9 - datalength(convert(varchar(9),rsr.pssn))) + convert(varchar(9),rsr.pssn) pssn
        ,   convert(char(1),rsr.filingStatus) filingStatus
        ,   convert(varchar(25),convert(int,rsr.refundAmount)) refundAmount
        ,   replicate('0',5 - len(convert(varchar(5),rsr.pin))) +  convert(varchar(5),rsr.pin) pin
        from
            dbo.tblRefundStatusRequest rsr join dbCrosslink17.dbo.tblTaxmast tm on rsr.pssn = tm.pssn
                and rsr.finalStatus = 0
                and rsr.filingStatus is not null
                and isnull(rsr.refundAmount,0) > 0
                and rsr.pin is not null
                --and rsr.pssn = isnull(@pssn,rsr.pssn)
            join Taxbrain17.dbo.tblReturn r on tm.rtn_id = r.ReturnID
                and r.RefundStatusAgreement = 'X'
                and r.ReturnDeleted is null
        order by
            rsr.reqId


    open curSdata
    fetch next from curSdata into @reqId,@ssn,@fstatus,@rAmount, @pin

    while @@fetch_status = 0
        begin
            set @fmtPost = null
            set @rData = null
            set @respCode = null
            set @errDesc = null
            set @pData = 'ssn=' + @ssn + '|filingStatus=' + @fstatus + '|refundDollarAmount=' + @rAmount + '|pin=' + @pin + '|clientId=petzent-440337051|lang=en'


            print 'Begin Processing: ' + @ssn + ' ...'
            --print 'Raw Data: ' + @pData

            exec dbAdmin.dbo.up_postJson @url, @pData, @fmtPost output, @rData output, @respCode output, @errDesc output

            print 'Formatted JSON Post Data: ' + @fmtPost
            print 'Return Data: ' + @rData
            print 'Response Code: ' + @respCode
            print 'Error Description: ' + @errDesc

            set @rXML = @rData

            insert [dbo].[tblRefundStatusResponse](
                [reqId]
            ,   [respCode]
            ,   [return_status]
            ,   [refundDate]
            ,   [respXml]
            ,   [finalStatus]
            ,   [sentJson]
			,	[delivered]
            )
                select
                    @reqId reqId
                ,   isnull(@respCode,0) respCode            
                ,   rs.rXML.value('(/refundStatus/status)[1]','varchar(100)') return_status
                ,   rs.rXML.value('(/refundStatus/refundDate)[1]','date') refundDate
                ,   @rXML respXml
                ,   isnull(rs.rXML.value('(/refundStatus/finalStatus)[1]','bit'),0) finalStatus
                ,   @fmtPost sentJson
				,	' ' delivered
                from    
                    (select @rXML rXML) rs     
      
                set @respId = scope_identity()

                print 'Inserted Response Id: ' + convert(varchar(25),@respId)

                if @respCode = '200'
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

            print 'End Processing: ' + @ssn + ' ...'

            fetch next from curSdata into @reqId,@ssn,@fstatus,@rAmount, @pin
        end

    close curSdata
    deallocate curSdata

