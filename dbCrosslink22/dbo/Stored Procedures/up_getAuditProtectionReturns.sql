

-- =============================================
-- Author:        Charles Krebs
-- Create date: 4/30/2013
-- Description:   Retrieve a list of all protection plus returns
-- Updates:
-- Changed 'Partially Funded' bank products to 'Unfunded'.  Charles Krebs 7/11/2013
-- Updated procedure to display non-bank product returns that are billable. Charles Krebs 1/7/2014
-- Changed pssn search to work with last 4 of social 2/6/2014
--
-- Refactored to remove the temporary table. 02/12/2015 KJE
-- remove 'AGUOLE' from results 2/27/2015 JW
-- remove 'AGUOLE' and embedded new table tblTaxMastFee with the appropriate tag. 1/29/2016
-- remove duplicate rows 3/30/2017 JW
-- =============================================
CREATE PROCEDURE [dbo].[up_getAuditProtectionReturns] 
    @account varchar(8)     = null
,   @userID int             = null
AS
    set nocount on

            select
            tm.pssn PrimarySSN
		,	protPlus.company [Product]
        ,   tm.user_id UserID
        ,   tm.filing_stat FilingStatus
        ,   u.account
        ,   e.Company
        ,   tm.pri_fname PrimaryFirstName
        ,   tm.pri_lname PrimaryLastName
        ,   tm.EFIN
        ,   tm.submissionid
		,	tm.irs_ack_dt AckDate
        ,   'Bank Product' BillingType
		,	case 
				when protPlusPayAmt >= protPlusFee and tm.isFullyFunded = 1 then 'Fully Funded'
				else 'Unfunded'
			end PaymentStatus
		,  case 
				when protPlusPayAmt >= protPlusFee and tm.isFullyFunded = 1 then convert(char(10), protPlusPayDate, 110)
				else ''
			end PaymentDate
        ,	tm.address
        ,	tm.city
        ,	tm.state
        ,	tm.zip
        from dbo.tblTaxmast tm 
            join dbCrosslinkGlobal.dbo.tblUser u on tm.user_id = u.[user_id] 
                and u.account = isnull(@account,u.account)   
                and tm.user_id = isnull(@userId,tm.user_id)
            left join dbo.efin e on tm.EFIN = e.Efin 
			INNER JOIN (
				select	tf1.pssn
				,		sum(reqAmount) [protPlusFee]
				,		sum(payAmount) [protPlusPayAmt]
				,		max(payDate) [protPlusPayDate]
				,		ap.company
				from	dbo.tblTaxMastFee tf1
				inner join tblAncillaryProduct ap on ap.tag = tf1.tag and ap.groupId = 3
				group by tf1.pssn, ap.company
				) protPlus on protPlus.pssn = tm.pssn
			--left join tblTaxmastFee tmf on tmf.pssn = tm.pssn
        where
                  tm.ral_flag = 5
                  AND tm.irs_acc_cd = 'A'

