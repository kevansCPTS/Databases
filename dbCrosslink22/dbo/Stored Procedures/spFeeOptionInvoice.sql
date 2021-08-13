

-- =============================================
-- Author:		Josh
-- Create date: 10/12/2012
-- Description:	Purpose is to balance what is owed
--				by the ERO to PEI in SB and ProtPlus Fees
--				for non-bank returns
-- Updated: 12/28/2012 By Charles Krebs
--			Added logic to support paying off SB Loans with
--			SB fees.  In addition, rewrote tblFeeOptionTransaction
--			inserts to avoid duplication of code.
-- Updated: 1/16/2013 By Charles Krebs
--			Fixed a bug that was preventing records from being inserted
-- Updated: 1/18/2013 By Charles Krebs
--			Fixed a bug that was returning records with $0
-- Updated: 2/4/2013 Updated for new requirement to include borrowers whether
--					 or not have opted in to the FeeOption program
-- Updated: 2/5/2013 Updated to include Record Types 5 when inserting into 
--					transaction table - Charles Krebs
-- Updated: 2/7/2013 Changed join to taxmaster to use pssn, filing status and userID
-- Updated: 2/11/2013 No longer including SB Fees as loan repayment for EFINs that 
--		did not opt in to Fee Option Program - Charles Krebs
-- Updated: 2/12/2013 Added logic to move SB Loan Payments into the passthrough Account
--		and log the adjustments with a new record type to avoid moving the money more
--		than once
-- Updated: 3/11/2013 Using a new stored procedure up_GetNonBankProductReturns to do the 
--		logic in determining Billable returns
-- =============================================
CREATE PROCEDURE [dbo].[spFeeOptionInvoice]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	/* Before doing anything, we want to allocate any money for SB Loan Payments to 
	the Accounts' passthrough buckets.  */

	/* First Get all prior Loan Invoices, Loan/PP Payments, and Prior Adjustments. 
	The EFIN and the BankID are irrelevant for RecordType 6, but we need a value so
	we will just take the minumums. */
	SELECT efin.Account, MIN(efin.efin) efin, MIN(BankID) BankID,
		IsNull(SUM(CASE WHEN RecordType = 5 THEN Amount END), 0) LoanInvoices,
		IsNull(SUM(CASE WHEN RecordType = 4 THEN Amount END), 0) Payments,
		ISNULL(Sum(CASE WHEN RecordType = 6 THEN Amount END), 0) PriorAdjustments
	INTO #LoanBalances
	FROM tblFeeOptionBalance FOB
		INNER JOIN efin On efin.efin = FOB.EFIN
	WHERE RecordType in (4, 5, 6)
	GROUP BY efin.Account

	DECLARE @LoanAccount varchar(10)
	DECLARE @LoanInvoices money
	DECLARE @Payments money
	DECLARE @PriorAdjustments money
	DECLARE @ActualPayments money
	DECLARE @NewPayment money
	DECLARE @LoanBankID char(1)

	DECLARE @loanEFIN int
	while exists (SELECT * FROM #LoanBalances)
	BEGIN
	
		SELECT Top 1 @LoanAccount = Account, 
			@loanEFIN = efin,
			@LoanBankID = BankID,
			@LoanInvoices = LoanInvoices,
			@Payments = Payments,
			@PriorAdjustments = PriorAdjustments
		FROM #LoanBalances
		/* The "Actual SB Loan Payments" year-to-date are the lesser of 
			1) Total SB Loan Payment Invoices
			2) Total SB Loan/PP Payments
		*/
		IF (@Payments < @LoanInvoices)
		BEGIN
			SET @ActualPayments = @Payments
		END
		ELSE 
		BEGIN
			SET @ActualPayments = @LoanInvoices
		END
		
		/* The Amount of the newly available payment is the year to 
			date "Actual SB Loan Payments" minus any prior adjustments. */
		SET @NewPayment = @ActualPayments - @PriorAdjustments
		
		/* If there is any new money available, place it in the passthrough account
		   and log the adjustment in this table so that we don't try to move the 
		   same money again. */
		IF (@NewPayment > 0)
		BEGIN
			--Insert RecordType 6 
			INSERT INTO tblFeeOptionBalance
			(EFIN, BankID, Amount, RecordType, YearToDateAmount, YearToDateReturnCount)
			VALUES
			(@loanEFIN, @LoanBankID, @NewPayment, 6, 0, 0)
			
			--Insert aptxn record
			DECLARE @adjReferenceID int;
			SELECT @adjReferenceID = Max(ref_id) + 1 FROM dbCrosslinkGlobal..aptxn WHERE txn_type = '4'			
			INSERT INTO dbCrosslinkGlobal..aptxn
			(ref_id, txn_type, txn_stat, txn_amt, account, note, txn_date, user_id, efin, ssn, ord_num)
			VALUES
			(@adjReferenceID, '4', 'O', @NewPayment, @LoanAccount, 'SB Loan Repayment', GETDATE(), 0, 0, 0, 0)
		END
		
		DELETE FROM #LoanBalances WHERE Account = @LoanAccount
	END


	DROP TABLE #LoanBalances

	   


	--LookupTypeID	LookupValue	LookupDescription
--1	SBOUT	SB Fee Balance
--2	PPOUT	PP Fee Balance
--3	SBIN	SB Fee Payment
--4	PPIN	PP Fee Payment
--5 SBLOAN	SB Loan Payment
	
	Declare @efin int
	Declare @account varchar(8)
	Declare @SBFeeYTD money
	Declare @PEIProtPlusFeeYTD money
	
	

	CREATE TABLE #BillableReturns
	(PrimarySSN int, 
	 UserID int, 
	 FilingStatus tinyint, 
	 GUID varchar(255),
	 SBFee money, 
	 PEIProtPlusFee money)

	INSERT INTO #BillableReturns
	exec up_getNonBankProductReturns	
   
	--Select the sum of fees grouped by efin into temp table
	select  count(*) as ReturnCount,RM.efin, 
		Sum(CASE WHEN b.AgreeFeeOption = 0 THEN 0 ELSE
		a.SBFee END) as SBFeeYTD, 
		Sum(CASE WHEN PPAccounts.AccountCode IS null THEN 0 ELSE 
		a.PEIProtPlusFee END) as PEIProtPlusFeeYTD,
		b.SelectedBank as bank, 
		b.Account, b.AgreeFeeOption 
		into #tempRollup 
		from #BillableReturns a 
		INNER JOIN tblReturnMaster RM ON RM.PrimarySSN = A.PrimarySSN
			AND RM.UserID = A.UserID
			AND RM.FilingStatus = A.FilingStatus
		inner join efin b on RM.EFIN=b.efin
		LEFT JOIN tblPPFeeOptionAccounts PPAccounts ON B.Account = PPAccounts.AccountCode
		LEFT JOIN tblTaxmast c with (nolock) ON a.PrimarySSN=c.pssn AND
			a.userID = c.user_id AND a.FilingStatus = c.filing_stat
		LEFT JOIN tblSBLoans d on d.Account=b.Account
		where ((CASE WHEN b.AgreeFeeOption = 0 Then 0 ELSE
			A.SBFee END) 
			+ (CASE WHEN PPAccounts.AccountCode IS null THEN 0 ELSE 
		A.PEIProtPlusFee END) > 0) and RM.EFIN is not null
		and b.SelectedBank is not null 
		group by RM.efin , b.SelectedBank, b.Account, 
			b.AgreeFeeOption, PPAccounts.AccountCode
		ORDER BY RM.EFIN
	
	
		
	--debug
	--select * from #tempRollUp	
		
	Declare @bank char(1)
	Declare @YTDReturnCount int
	Declare @SBOutAmount money
	Declare @PPOutAmount money
	Declare @FeeOptionFlag bit
		
	--Loop over temp table for each efin
	While (Select Count(*) From #tempRollup) > 0
	Begin
		 Select Top 1 @efin = efin,@bank=bank,@YTDReturnCount=ReturnCount,
						@SBFeeYTD=SBFeeYTD, @PEIProtPlusFeeYTD=PEIProtPlusFeeYTD, 
						@account=Account, @FeeOptionFlag=AgreeFeeOption From #tempRollup


		SET @SBOutAmount = 0
		SET @PPOutAmount = 0
		--For current efin find out how much we are planning/have invoiced for already
		--For SBOUT
		select @SBOutAmount=IsNull(SUM(amount), 0) from tblFeeOptionBalance 
				where efin=@efin and RecordType in (1, 5) group by efin--SBOUT AND SBLOAN
		--For ProtPlus
		select @PPOutAmount=IsNull(SUM(amount), 0) from tblFeeOptionBalance 
				where efin=@efin and RecordType=2 group by efin--PPOUT

		--Calculate if we are short on our invoice amount
		if(@SBFeeYTD > @SBOutAmount)
		begin
			Declare @SBDiff money
			Declare @LoanBalance money
			
			SET @SBDiff = @SBFeeYTD - @SBOutAmount

			/* Determine whether the SB owes money for a loan. */
			exec spGetSBLoanBalance @Account, @LoanBalance out
			
			if (@LoanBalance > 0) 
			-- Money is owed to pay off a Service Bureau loan
			BEGIN
				/* To Store the amount of the loan payment to be made from SB Fees */
				DECLARE @LoanPayment money 
				
				IF (@LoanBalance >= @SBDiff)
				-- All pending SB Fees go to loan payment
				BEGIN
					SET @LoanPayment = @SBDiff
					--Zero out SB Portion of deposit request
					SET @SBDiff = 0
				END
				ELSE 
				-- Some SB Fees will be left over after loan payment
				BEGIN
					SET @LoanPayment = @LoanBalance
					--Subtract the loan payment portion and leave the rest for the SB
					SET @SBDiff = @SBDiff - @LoanPayment
				END

				--Insert Loan Payment record
				insert into tblFeeOptionBalance
				(EFIN,BankID,Amount,RecordType,RecordDate,YearToDateAmount,YearToDateReturnCount)
					values
				(@efin, @bank,@LoanPayment, 5, GETDATE(), @SBFeeYTD, @YTDReturnCount)
				
			END
			
			IF (@SBDiff > 0 and @FeeOptionFlag  = 1) 
			BEGIN
				--Insert SB Deposit record
				insert into tblFeeOptionBalance
				(EFIN,BankID,Amount,RecordType,RecordDate,YearToDateAmount,YearToDateReturnCount)
					values
				(@efin, @bank,@SBDiff, 1, GETDATE(), @SBFeeYTD, @YTDReturnCount)
			END
		end

		if(@PEIProtPlusFeeYTD > @PPOutAmount)
		begin
			--This means ERO owes more money for PP			
			Declare @PPDiff money
			set @PPDiff = @PEIProtPlusFeeYTD - @PPOutAmount  
			insert into tblFeeOptionBalance
			(EFIN,BankID,Amount,RecordType,RecordDate,YearToDateAmount,YearToDateReturnCount)
				values
			(@efin, @bank,@PPDiff, 2, GETDATE(), @PEIProtPlusFeeYTD, @YTDReturnCount)
			
		end		


		Delete FROM #tempRollUp Where efin = @efin --increment
	End



	drop table #tempRollUp

	DELETE FROM tblFeeOptionTransaction WHERE [sent] = 0 AND sentDate is null
	
	--Group by efin
	SELECT FOB.efin, FOB.recordType, FOB.BankID, SUM(FOB.Amount) Balance, 
		IsNull((SELECT SUM(Amount) FROM tblFeeOptionTransaction
			WHERE RecordType = FOB.RecordType AND EFIN = FOB.EFIN 
			AND BankID = FOB.BankID AND [sent] = 1), 0) PriorTransactions,
		ROW_NUMBER() OVER(ORDER BY FOB.efin, FOB.RecordType, FOB.BankID) RowID
			
	INTO #TempBalance			
	FROM tblFeeOptionBalance FOB
	GROUP BY FOB.efin, FOB.RecordType, FOB.BankID

	
	DECLARE @CursorEFIN int
	DECLARE @CursorRecordType int
	DECLARE @CursorBankID varchar(1)
	DECLARE @CursorBalance money
	DECLARE @CursorPriorTransactions money
	DECLARE @CursorAmountDue money
	DECLARE @CursorRowID int
	
	WHILE Exists(SELECT * FROM #TempBalance WHERE Balance > PriorTransactions)
	BEGIN
		SELECT TOP 1 @CursorEFIN = efin, 
			@CursorRecordType = RecordType, 
			@CursorBankID = BankID,
			@CursorBalance = Balance,
			@CursorPriorTransactions = PriorTransactions,
			@CursorRowID = RowID
		FROM #TempBalance
		WHERE Balance > PriorTransactions
		
		SET @CursorAmountDue = @CursorBalance - @CursorPriorTransactions
		
		IF @CursorRecordType in (1,2, 5)
		BEGIN
		
			INSERT INTO tblFeeOptionTransaction(BankID, efin, RecordType, amount)
			VALUES (@CursorBankID, @CursorEFIN, @CursorRecordType, @CursorAmountDue)
		END
		
		DELETE FROM #TempBalance WHERE RowID = @CursorRowID
		
	END
	
	
		
	--debug
	--select * from tblFeeOptionTransaction
    
   --clean up
   drop table #tempBalance
   
END




