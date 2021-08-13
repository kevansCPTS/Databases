
CREATE procedure [dbo].[up_rptProtPlusEROEnrollStatus] 
    @account varchar(8) = null
,   @status bit = null
as

--declare @account varchar(8)
--declare @status bit 
--set @account = null
--set @status = 1

    set nocount on

    select
        e.UserID
    ,   ppes.efin
    ,   ppes.account [Account Name]
    ,   isnull(e.FirstName,'') + ' ' + isnull(e.LastName,'') [Contact Name]
    ,   e.Company [Company Name]
    ,   case 
            when ppes.eStatus = 1 then 'Accepted'
            when ppes.eStatus = 0 and ppel.responseCode is not null then 'Rejected - (' + convert(varchar(10),ppel.responseCode) + ') ' + ppel.responseData
            when ppes.eStatus = 0 and ppel.responseCode is null then 'Missing Information - (' + ppel.responseData + ')'
            else 'Pending'
        end [Status]    
    ,   ppes.statusDate [Last Update]

    from
        [dbo].[tblProtPlusEROEnrollStatus] ppes join [dbo].[efin] e on ppes.efin = e.Efin
            and ppes.account = isnull(@account,ppes.account)
            and ppes.eStatus = isnull(@status,ppes.eStatus)        
        left join [dbo].[tblProtPlusEROEnrollLog] ppel on ppes.logId = ppel.logId

