-- ==========================================================
-- Author:		Chuck Robertson
-- Create date: 09/22/2010
-- Description:	This stored procedure will return the Total 
--				of all Sub-items for a given Product Code
-- ==========================================================
CREATE PROCEDURE [dbo].[spGetOrderSubItemTotal]
	@ParentCode		varchar(4),
	@Season			varchar(4),
	@SubItemTotal	money output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProdCode varchar(4), @Qty int, @Price money, @SequenceNumber int, @ItemTotal money

	SET @ItemTotal = 0

	-- Create Cursor to loop through Order Items.
	DECLARE cur_OrderItems CURSOR FOR
		SELECT ord_stock.prod_cd, ord_stock.qty, ord_stock.uprice, sequence_number
		FROM ord_stock, ord_pkg 
		WHERE ord_stock.prod_cd = ord_pkg.child_cd AND ord_pkg.parent_cd = @ParentCode
		AND ord_stock.season = ord_pkg.season AND ord_stock.season = @Season
		order by sequence_number

	-- Open the cursor.
	OPEN cur_OrderItems

	-- Retrieve the first record.
	FETCH cur_OrderItems INTO @ProdCode, @Qty, @Price, @SequenceNumber

	-- Loop through the records
	WHILE (@@FETCH_STATUS=0)
	BEGIN

		-- Add the Sub-Item Price to the total.
		SELECT @ItemTotal = @ItemTotal + @Price

		-- Fetch the next record.
		FETCH cur_OrderItems INTO @ProdCode, @Qty, @Price, @SequenceNumber
	END

	-- Close the cursor.
	CLOSE cur_OrderItems

	-- Clean up memory.
	DEALLOCATE cur_OrderItems

	-- Select the value back to return to the caller.
	SELECT @SubItemTotal = @ItemTotal
END


