
-- exec [up_getProductStatus] 'rivedg', 43160, 912913
CREATE procedure [dbo].[up_getProductStatus] 
    @AccountID        varchar(8)
,   @UserID     int             = null
,	@EFIN	int = null
as

declare @ParentAccount varchar(8) = @AccountID

if @AccountID is null
begin
select @ParentAccount = account from tblUser where user_id = @UserID
end

declare @MasterID int 
select @MasterID = master_user_id from tblXlinkAccounts where account_id = @ParentAccount

select
    er1.Efin
,   er1.CompanyName    
,	er1.ParentUserID as Parent
,	er1.UserID
--,	er1.account
,   er1.Bank
--,   er1.BankAppID
--,   ISNULL(er1.EfinProduct,'') as EfinProduct
--,   ISNULL(er1.EfinProduct2,'') as EfinProduct2
--,	ISNULL(er1.EfinCompliance,'') as EfinCompliance
--,	ISNULL(er1.EfinCard,'') as EfinCard
--,	ISNULL(er1.EfinPrint,'') as EfinPrint
,   rsd.Description as EfinStatus
,   er1.ProductStatus
,   er1.LoanAdvance
,	er1.eCompliance
,	er1.eCard
,	er1.ePrint
,   er1.ResponseDate
from
    (
        select
            er.Efin
        ,   ef.Company as CompanyName    
		,	ef.UserID
		,	u.account
		,	isnull(isnull(fo.UserID, fc.ParentUserID), @MasterID) ParentUserID
        ,   er.ResponseDate
        ,   er.BankCode
        ,   er.BankAppID
        ,   er.EfinProduct
        ,   er.EfinProduct2
        ,   er.EfinStatus
		,	er.EfinCompliance
		,	er.EfinCard
		,	er.EfinPrint
        ,   case 
                when isnull(er.BankCode, '') = 'S' then 'TPG'
                when isnull(er.BankCode, '') = 'W' then 'World'
                when isnull(er.BankCode, '') = 'V' then 'Refund Adv'
                when isnull(er.BankCode, '') = 'R' then 'Republic'
                when isnull(er.BankCode, '') = 'F' then 'Refundo'
                else ''
            end Bank
        ,   case 
                when isnull(er.EfinCompliance, '') = 'U' then 'Unknown'
                when isnull(er.EfinCompliance, '') in ('X','Y') then 'Yes'
                when isnull(er.EfinCompliance, '') = 'N' then 'No'
                else ''
            end eCompliance
        ,   case 
                when isnull(er.EfinCard, '') = 'X' then 'Opted in'
                when isnull(er.EfinCard, '') = '1' then 'Instant'
                when isnull(er.EfinCard, '') = '2' then 'Personalized'
                when isnull(er.EfinCard, '') = '3' then 'Instant Personalized'
                when isnull(er.EfinCard, '') = 'N' then 'None'
                when isnull(er.EfinCard, '') = 'U' then 'Eligible, not opted in'
                else ''
            end eCard
        ,   case 
                when isnull(er.EfinPrint, '') = 'D' then 'Desktop'
                when isnull(er.EfinPrint, '') in ('X','R') then 'Remote'
                else ''
            end ePrint
        ,   case 
                when er.BankCode = 'F' and isnull(er.efinproduct, '') = 'T' then 'Waiting for compliance'
                when er.BankCode = 'F' and isnull(er.efinproduct, '') = 'E' then 'RT and NOW'
                when er.BankCode = 'F' and isnull(er.efinproduct, '') = 'O' then 'RT only'
                when er.BankCode = 'F' and isnull(er.efinproduct, '') = 'D' then 'Office Closed, no products'

                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'A' then 'Approved'
                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'B' then 'RT and EA Basic(ERO)'
                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'D' then 'RT and EA Basic(Taxpayer)'
                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'P' then 'RT and EA Plus'
                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'S' then 'RT and EA Standard'
                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'E' then 'RT only'
                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'T' then 'Not eligible'
                when er.BankCode = 'R' and isnull(er.efinproduct, '') = 'F' then 'Pending'

                when er.BankCode in('S','W') and isnull(er.efinproduct, '') = 'E' then 'FastCash and RT'
                when er.BankCode in('S','W') and isnull(er.efinproduct, '') = 'O' then 'RT Only'
                when er.BankCode in('S','W') and isnull(er.efinproduct, '') = 'D' then 'Denied, no products'

                when er.BankCode = 'V' and isnull(er.efinproduct, '') = 'E' then 'Loan/Advance and RT'
                when er.BankCode = 'V' and isnull(er.efinproduct, '') = 'O' then 'RT Only'
                when er.BankCode = 'V' and isnull(er.efinproduct, '') = 'D' then 'Denied, no products'
                else ''
            end ProductStatus
        ,   case 
                when isnull(er.efinproduct2, '') = 'Y' then 'Approved Loan/Advance'
                when isnull(er.efinproduct2, '') = 'N' then 'Not approved'

                when er.BankCode in('S','W') and isnull(er.efinproduct2, '') = 'A' then 'Opted in FastCash'
                --when er.BankCode in('S','W') and isnull(er.efinproduct2, '') = '' then 'Not approved' -- Is this correct?

                when er.BankCode = 'V' and isnull(er.efinproduct2, '') = 'U' then 'Eligible, not opted in'
                else ''
            end LoanAdvance
        ,   row_number() over ( partition by er.efin, er.BankCode order by er.ResponseDate desc) AS 'RowNumber'   
        from
            dbo.efin_regr er 
			join efin ef on ef.Efin = er.Efin
			join dbCrosslinkGlobal.dbo.tblUser u on ef.UserID = u.user_id
			left join dbo.FranchiseOwner fo on ef.UserID = fo.UserID
			left join dbo.FranchiseChild fc on ef.UserID = fc.ChildUserID
			where er.Efin = @EFIN or isnull(@EFIN, 0) = 0
    ) er1

join ltblBankRegistrationStatus brs on brs.BankID = er1.BankCode and brs.EFINStatus = er1.EfinStatus
join ltblRegistrationStatusDescription rsd on rsd.Registered = brs.Registered

where
    er1.RowNumber = 1 
	and (er1.UserID = isnull(@UserID,er1.UserID) 
	or er1.ParentUserID = isnull(@UserID,er1.ParentUserID))
	and er1.account = isnull(@AccountID,er1.account) 


order by 
    er1.ParentUserID, er1.UserID, er1.Efin
