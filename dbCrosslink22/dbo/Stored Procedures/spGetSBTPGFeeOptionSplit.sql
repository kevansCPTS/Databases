-- =============================================
-- Author:		Charles Krebs
-- Create date: 12/11/2012
-- Description:	Determine the portions of the parameter Total to allot for the Service Bureau and Protetion Plus
-- =============================================
CREATE PROCEDURE [dbo].[spGetSBTPGFeeOptionSplit] 
	-- Add the parameters for the stored procedure here
	@efin int, 
	@total money
AS
BEGIN
	DECLARE @sbPercentage float
	DECLARE @ppPercentage float
	DECLARE @ytdSBFeeBalance float -- 1 - 3
	DECLARE @ytdPPFeeBalance float  -- 2 - 4
	DECLARE @ppPortion money
	DECLARE @sbPortion money

	--Determine the SB and PP balances using year to date invoices minus 
	--year to date disbursements
	SELECT @ytdSBFeeBalance = IsNull(SUM(CASE WHEN RecordType = 1 THEN Amount END), 0)
		- IsNull(SUM(CASE WHEN RecordType = 3 THEN Amount END), 0),
	@ytdPPFeeBalance = IsNull(SUM(CASE WHEN RecordType IN (2, 5) THEN Amount END), 0) 
		- IsNull(SUM(CASE WHEN RecordType = 4 THEN Amount END), 0)
	FROM tblFeeOptionBalance
	WHERE BankID = 'S'
	AND EFIN = @efin


	--If both balances are greater than zero, the percentages need to be calculated
	IF (@ytdPPFeeBalance > 0 AND @ytdSBFeeBalance > 0) 
	BEGIN
		SET @sbPercentage = @ytdSBFeeBalance / (@ytdSBFeeBalance + @ytdPPFeeBalance)
		SET @ppPercentage = @ytdPPFeeBalance / (@ytdSBFeeBalance + @ytdPPFeeBalance)
		
		print @sbPercentage
		print @ppPercentage
		
	END
	ELSE 
	BEGIN
		-- Based on the outer IF statement, at most one of these will be greater than zero
		SET @sbPercentage = (CASE WHEN @ytdSBFeeBalance > 0 THEN 1 ELSE 0 END)
		SET @ppPercentage = (CASE WHEN @ytdPPFeeBalance > 0 THEN 1 ELSE 0 END)
	END

	SET @ppPortion = @total * @ppPercentage  
	--SET @sbPortion = @total * @sbPercentage   
	
	
	--Josh:Round off the partial pennies
	SET @ppPortion = ROUND(@ppPortion,2)   
	--SET @sbPortion = ROUND(@sbPortion,2)
	
	
	
	--This is to eliminate SB getting everything
	--If ppPortion is zero or less and sbPortion is zero or less
	if(@sbPercentage > 0) 
	BEGIN
		SET @sbPortion = @total - @ppPortion
	END
	ELSE
	BEGIN
		SET @sbPortion = 0
	END
	
	--if(@sbPercentage > 0) 
	--BEGIN
--		SET @sbPortion = @total - @ppPortion
--	END
	
	
	SELECT @ppPortion PPPortion, @sbPortion SBPortion
END


