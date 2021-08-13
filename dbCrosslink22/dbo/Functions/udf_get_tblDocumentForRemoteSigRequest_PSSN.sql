
CREATE FUNCTION udf_get_tblDocumentForRemoteSigRequest_PSSN (@xData xml)
RETURNS int
With Schemabinding
as
BEGIN
   DECLARE @pid int
   SELECT @pid = @xData.value('(/REMOTEMETADATA/PSSN)[1]', 'int')
   RETURN @pid 
END
