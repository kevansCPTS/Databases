CREATE PROCEDURE [dbo].[up_getTaxmastExistsBySSN] --400004103
    @pssn       int
,   @exists     bit     output
as

    set nocount on; 

    set @exists = 0;

    if exists (select tm.pssn from dbo.tblTaxmast tm where tm.pssn = @pssn)
        set @exists = 1;
