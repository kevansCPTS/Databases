/****** Object:  Stored Procedure dbo.csrspReturnGetEmployers    Script Date: 5/5/2009 2:50:31 PM ******/
-- =============================================
-- Author:		Charles Krebs
-- Create date: 1/18/2009
-- Description:	Return a list of Employer names from 
--	W-2's with the indicated ReturnID.
-- =============================================
CREATE PROCEDURE [dbo].[csrspReturnGetEmployers]
@returnID int,
@year int
AS
BEGIN
	SET ARITHABORT ON
	SET ANSI_NULLS OFF
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@year is null) 
	BEGIN
		SELECT 5
	END
	ELSE IF (@year = 2013)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain13..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2012)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain12..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2011)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain11..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2010)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain10..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2009)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain9..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2008)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain8..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2007)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain7..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2006)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain6..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2005)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain5..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2004)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain4..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END
	ELSE IF (@year = 2003)
	BEGIN
		SELECT 	W2.f0050 EmployerName
		FROM taxbrain3..tblForm_W2 W2
		WHERE ReturnID = @returnID
	END

END
-- GRANT EXECUTE ON csrspReturnGetEmployers TO taxman_csr

