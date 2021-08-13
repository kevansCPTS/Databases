
-- =============================================
-- Author:		Sundeep Brar
-- Create date: 06/04/2020
-- Description:	Stored procedure for inteneral report > customer support report > Bank Enrollment Status
-- =============================================
CREATE PROCEDURE [dbo].[up_rptBankEnrollmentStatus]

AS

BEGIN
	select
		a.Bank
	,   sum(case when a.registered = 'A' then a.numRecords else 0 end) Approved
	,   sum(case when a.registered = '-' then a.numRecords else 0 end) Cancelled
	,   sum(case when a.registered = 'D' then a.numRecords else 0 end) Denied
	,   sum(case when a.registered = 'P' then a.numRecords else 0 end) Pending
	,   sum(case when a.registered = 'X' then a.numRecords else 0 end) Rejected
	,   sum(case when a.registered = 'S' then a.numRecords else 0 end) Suspended
	,   sum(case when a.registered = 'U' then a.numRecords else 0 end) Unsubmitted    
	from
		(
			select
				ba.BankID
			,   ba.Bank
			,   ba.Registered
			,   ba.RegisteredDescription
			,   count(ba.BankAppID) numRecords
			from
				(
					select
						ba1.BankID
					,   ba1.Bank
					,   ba1.BankAppID
					,   ba1.EFin
					,   ba1.Registered
					,   ba1.RegisteredDescription
					,   row_number() over (partition by ba1.Efin, ba1.BankId order by ba1.BankAppID desc) rowNum
					from
						dbo.vwBankApplication ba1
					where 
						ba1.Deleted != 1
				) ba 
			where
				ba.rowNum = 1
				and ba.Registered in('A','-','D','P','X','S','U') 
			group by
				ba.BankID
			,   ba.Bank
			,   ba.Registered
			,   ba.RegisteredDescription    
		) a
	group by
		a.Bank
	order by
		a.Bank

END

