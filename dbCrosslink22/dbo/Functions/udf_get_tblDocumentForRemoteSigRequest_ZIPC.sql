
CREATE FUNCTION [dbo].[udf_get_tblDocumentForRemoteSigRequest_ZIPC] (@xData xml)
RETURNS varchar(15)
With Schemabinding
as
BEGIN
   DECLARE @zip varchar(15)
   SELECT @zip = @xData.value('(/REMOTEMETADATA/ZIPC)[1]', 'varchar(15)')
   RETURN @zip
END
