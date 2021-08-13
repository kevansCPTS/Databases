
/************************************************************************************************
Name: up_rptFedRejectErr

Purpose: 
    Replace the below SQL with a stored procedure to optimize query performance for the report.


        exec sp_executesql N'select dbo.PadString(fr.efin,''0'',6) EFIN, dbo.PadString(fr.pssn,''0'',9) SSN, reject, descr, tran_key, tran_seq, rowID from vwFederalRejects fr
	        inner join rejdescr rd on rd.reject = fr.FedCode
        WHERE @SESSION_type = ''account'' AND fr.account = @SESSION_accountid

        UNION ALL

        SELECT    dbo.PadString(tm.efin, ''0'', 6) EFIN, dbo.PadString(rej.pssn, ''0'', 9) SSN, rtrim(Convert(varchar(MAX), RuleNumber)) reject, 
	        rTrim(Convert(varchar(MAX), ErrorMessage)) descr, '''' tran_key, '''' tran_seq, MEFErrorID rowID
        FROM         dbo.MEFError AS rej INNER JOIN
                              dbo.tblTaxmast AS tm ON tm.pssn = rej.pssn INNER JOIN
                              dbCrosslinkGlobal.dbo.tblUser AS u ON u.user_id = tm.user_id
        WHERE @SESSION_type = ''account'' AND u.account = @SESSION_accountid

        order by ssn, rowID',N'@SESSION_accountid nvarchar(6),@SESSION_type nvarchar(7)',@SESSION_accountid=N'JEAAND',@SESSION_type=N'account'


Called By:
    Reporting Services Report

Parameters: 
 1 @SESSION_accountid varchar(25)
 2 @SESSION_type varchar(25)

Result Codes:
 0 success

Author: Ken Evans 02/01/2013

Changes/Update:
    None.    

 
**************************************************************************************************/
CREATE procedure [dbo].[up_rptFedRejectErr] --'JEAAND', 'account'
    @SESSION_accountid varchar(25)
,   @SESSION_type varchar(25)
as


--declare @SESSION_accountid varchar(25)
--declare @SESSION_type varchar(25)


declare @output table(
    EFIN                varchar(6)
,   SSN                 varchar(9)
,   reject              varchar(50)
,   descr               varchar(50)
,   tran_key            varchar(10)
,   tran_seq            int
,   rowId               int
) 

set nocount on 

    --select
    --    @SESSION_type = 'account'
    --,   @SESSION_accountid = 'JEAAND'


    if (@SESSION_type != 'account')
        begin
            select 
                EFIN
            ,   SSN
            ,   reject
            ,   descr
            ,   tran_key
            ,   tran_seq
            ,   rowID 
            from
                @output        
        end
    else
        begin
            select
                dbo.PadString(tm.efin, '0',6) efin
            ,   dbo.PadString(r.pssn, '0',9) ssn
            ,   rtrim(rd.reject) reject
            ,   rtrim(rd.descr) descr
            ,   r.tran_key
            ,   r.tran_seq
            ,   r.rowID
            from    
                dbCrosslinkGlobal.dbo.tblUser u join dbo.tblTaxmast tm on u.[user_id] = tm.[user_id] 
                    and u.account = @SESSION_accountid
                join dbo.tblRejects r on tm.pssn = r.pssn
                join dbo.rejdescr rd on 'US' + r.rej_code = rd.reject
            union select
                dbo.PadString(tm.efin, '0',6) efin
            ,   dbo.PadString(er.primid, '0',9) ssn
            ,   rtrim(er.RuleNumber) reject
            ,   rtrim(er.ErrorMessage) descr
            ,   '' tran_key
            ,   '' tran_seq
            ,   er.MEFErrorID rowID
            from    
                dbCrosslinkGlobal.dbo.tblUser u join dbo.tblTaxmast tm on u.[user_id] = tm.[user_id] 
                    and u.account = @SESSION_accountid
                join dbo.MEFError er on tm.pssn = er.primid
            order by
                ssn
            ,   rowID
        end


grant exec on up_rptFedRejectErr to report


