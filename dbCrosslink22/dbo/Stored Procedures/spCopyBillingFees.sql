-- =============================================
-- Author:		Jay Willis
-- Create date: 12/1/2010
-- Description:	Copy Billing Fees
-- =============================================
CREATE PROCEDURE [dbo].[spCopyBillingFees]
	-- Add the parameters for the stored procedure here
	@from_schedule_id int,
	@to_schedule_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		IF NOT EXISTS (SELECT * FROM tblxlinkbilling WHERE schedule_id = @to_schedule_id)
			BEGIN
				INSERT INTO tblxlinkbilling SELECT state_id, form_id, form_type, account_id, form_price, @to_schedule_id, 
				franchiseuser_id, xmltagname
				FROM tblxlinkbilling where schedule_id = @from_schedule_id
			END

		IF NOT EXISTS (SELECT * FROM tblXlinkDiscounts WHERE schedule_id = @to_schedule_id)
			BEGIN
				INSERT INTO tblXlinkDiscounts
				(account_id, 
				discount_name_1, discount_amount_1, 
				discount_name_2, discount_amount_2, 
				discount_name_3, discount_amount_3, 
				discount_name_4, discount_amount_4, 
				discount_name_5, discount_amount_5, 
				discount_name_6, discount_amount_6, 
				schedule_id, franchiseuser_id, 
				discount_percent_1, discount_percent_2, 
				discount_percent_3, discount_percent_4, 
				discount_percent_5, discount_percent_6, override_fee)
				 SELECT account_id, 
				discount_name_1, discount_amount_1, 
				discount_name_2, discount_amount_2, 
				discount_name_3, discount_amount_3, 
				discount_name_4, discount_amount_4, 
				discount_name_5, discount_amount_5, 
				discount_name_6, discount_amount_6, 
				@to_schedule_id, franchiseuser_id, 
				discount_percent_1, discount_percent_2, 
				discount_percent_3, discount_percent_4, 
				discount_percent_5, discount_percent_6, override_fee
				FROM tblXlinkDiscounts where schedule_id = @from_schedule_id
			END

END


