-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prcRejects]
	-- Add the parameters for the stored procedure here
    @pssn integer,
    @tran_key char(1),
    @tran_seq integer,
    @error_num smallint,
    @form_seq char(4),
    @field_seq char(4),
    @rej_code char(4),
    @user_id char(6),
    @user_dcnx char(12),
    @rtn_id char(9),
    @irs_state_only char(2)

AS
BEGIN
	IF NOT EXISTS ( select pssn from tblRejects where pssn = @pssn AND tran_key = @tran_key
					AND tran_seq = @tran_seq AND error_num = @error_num)
	BEGIN 
		INSERT INTO tblRejects
		( pssn, tran_key, tran_seq, error_num, form_seq, field_seq,
		  rej_code, user_id, user_dcnx, rtn_id, irs_state_only)
		VALUES
		( @pssn, @tran_key, @tran_seq, @error_num, @form_seq, @field_seq,
		  @rej_code, @user_id, @user_dcnx, @rtn_id, @irs_state_only)
	END
	ELSE
	BEGIN 
		UPDATE tblRejects 

		SET pssn = @pssn,			tran_key = @tran_key,	tran_seq = @tran_seq, 
			error_num = @error_num, form_seq = @form_seq,	field_seq = @field_seq,
			rej_code = @rej_code,	user_id = @user_id,		user_dcnx = @user_dcnx, 
			rtn_id = @rtn_id,		irs_state_only = @irs_state_only

        WHERE pssn = @pssn AND tran_key = @tran_key AND tran_seq = @tran_seq AND error_num = @error_num
	END
END


