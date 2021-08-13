CREATE PROCEDURE [dbo].[spIphoneGetUserDetail] 
	@user varchar(10)

AS

SELECT 
COUNT(TM.pssn) AS Total, 
COUNT(case when TM.irs_acc_cd = 'A' then TM.pssn end) AS Acks, 
COUNT(case when TM.irs_acc_cd = 'R' then TM.pssn end) AS Rejects, 
COUNT(case when (TM.irs_acc_cd <> 'A' AND TM.irs_acc_cd <> 'R') then TM.pssn end) AS Other, 
COUNT(case when TM.ral_flag = 3 then TM.pssn end) AS Rals, 
COUNT(case when TM.ral_flag = 5 then TM.pssn end) AS Racs, 
COUNT(case when TM.ral_flag = 1 then TM.pssn end) AS Paper, 
COUNT(case when TM.ral_flag = 4 then TM.pssn end) AS BDue, 
COUNT(case when TM.ral_flag = 2 then TM.pssn end) AS Direct, US.Paid FROM tblTaxmast AS TM with (nolock), 

(SELECT isnull(paid_amt,0) AS Paid FROM user_stats WHERE user_id = @user
AND season = dbo.getXlinkSeason()) As US 

WHERE TM.user_id = @user GROUP BY TM.user_id, US.Paid


