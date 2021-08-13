
CREATE FUNCTION [dbo].[udfGetCharacters](
    @myString varchar(max)
,   @validChars varchar(100))
RETURNS 
    varchar(max) 
as
begin

    while @myString like '%[^' + @validChars + ']%'
        select @myString = replace(@myString,substring(@myString,patindex('%[^' + @validChars + ']%',@myString),1),'')

    return @myString

end

