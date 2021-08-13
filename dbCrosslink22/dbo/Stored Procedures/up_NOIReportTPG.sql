


-- =============================================
-- Author:		Kurtis Kim/Bill Litz
-- Create date: 1/16/2018
-- Description:	create delimited list of un-ack'd Bank Product returns
-- =============================================
CREATE PROCEDURE [dbo].[up_NOIReportTPG] 
	-- No parameters at this time - Add the parameters for the stored procedure here
	-- @bankId char(1),
	-- @agingDays int
AS
BEGIN

-- State Only RTs
-- VFY for No Advance for State Only RTs

--select la.sig_date, la.req_loan_amt, tm.ret_stat, tm.irs_acc_cd, tm.irs_ack_dt, tm.FORM_TYPE_1040, tm.submissionid, sm.state_ack, *
--from   dbcrosslink17..tbltaxmast tm
--inner join dbcrosslink17..tblstamast sm on sm.pssn = tm.pssn and sm.user_id = tm.user_id
--inner join dbcrosslink17..tblLoanApp la on la.pssn = tm.pssn and la.user_id = tm.user_id
--where  sm.state_ralf = 3
--and    rtrim(tm.submissionid) = ''
----and    la.req_loan_amt <> 0
--and    tm.ret_stat not in ('G', 'S')
--and la.sig_date < 20170301
--order by la.sig_date desc

-- Federal RTs
set nocount on;
select REPLACE(CAST(getdate() as date), '-' , '') +'|' -- NoticeDate
 + rtrim(t.pri_fname) + '|' -- AppFirstName
 + rtrim(t.pri_lname) +'|' -- AppLastName
 + rtrim(t.address) + '|' -- AppAddress1
 + '' + '|' -- AppAddress2,
 + rtrim(t.city) + '|' -- AppCity
 + rtrim(t.state) + '|' -- AppState
 + SUBSTRING(t.zip, 1, 5) + '|' -- AppZip
 + '600' -- PartnerID
 as dataLine
from dbCrosslink18..tblTaxmast t
inner join dbCrosslink18..tblLoanApp la on la.pssn = t.pssn
where t.ral_flag='5' and t.bank_id in('S', 'W') and t.req_loan_amt > 0 and t.irs_acc_cd!='A' 
 and la.sig_date < getdate() -21 -- sig_date is <= 21 days
 and la.sig_date > getdate() -22 -- sig_date >= 21

UNION

-- State Only RTs
--set nocount on;
select REPLACE(CAST(getdate() as date), '-' , '') + '|' -- NoticeDate
 + rtrim(t.pri_fname) + '|' -- AppFirstName
 + rtrim(t.pri_lname) + '|' -- AppLastName
 + rtrim(t.address) + '|' -- AppAddress1
 + '' + '|' -- AppAddress2
 + rtrim(t.city) + '|' -- AppCity
 + rtrim(t.state) + '|' -- AppState
 + SUBSTRING(t.zip, 1, 5) + '|' -- AppZip
 + '600' -- PartnerID
 as dataLine
from dbCrosslink18..tblLoanApp la
inner join dbCrosslink18..tblTaxmast t on t.pssn = la.pssn
inner join dbCrosslink18..tblStamast s on s.pssn = la.pssn
where t.ral_flag!='5' and t.bank_id in('S', 'W') and t.req_loan_amt > 0 and s.state_ralf='3' and s.state_ack!='A' 
 and la.sig_date < getdate() -21 -- sig_date is <= 21 days
 and la.sig_date > getdate() -22 -- sig_date >= 21

--select pssn, status, bank_id, req_loan_amt from dbcrosslink18..tblLoanApp 
--where status is null or status ='A' and bank_id='R' and req_loan_amt > 0
-- 12/4/17 results in 11/13/17 dates
--select pssn, postmark, resp_date from tbltaxmast 
--where resp_date < getdate() -21     -- 21 days from 20171204 =>  <= 20171113
--and resp_date > getdate() -22		--						 >= 20141113
--order by resp_date desc

END




