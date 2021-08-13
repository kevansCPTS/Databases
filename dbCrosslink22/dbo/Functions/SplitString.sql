
CREATE FUNCTION [dbo].[SplitString] 
(
    @myString VARCHAR(500),
    @deliminator VARCHAR(10)
)
RETURNS @ReturnTable TABLE 
(
    [id] INT IDENTITY(1,1) NOT NULL,
    [item] VARCHAR (100) NULL
)
AS
BEGIN
-- Source: http://stackoverflow.com/questions/2647/split-string-in-sql

        DECLARE @iSpaces INT
        DECLARE @part VARCHAR(50)

        --initialize spaces
        SELECT @iSpaces = CHARINDEX(@deliminator,@myString,0)
        WHILE @iSpaces > 0

        BEGIN

            INSERT INTO @ReturnTable (item)
            VALUES (SUBSTRING(@myString,0,CHARINDEX(@deliminator,@myString,0)))

			SELECT @myString = SUBSTRING(@mystring,CHARINDEX(@deliminator,@myString,0)+ LEN(@deliminator),LEN(@myString) - CHARINDEX(' ',@myString,0))
            SELECT @iSpaces = CHARINDEX(@deliminator,@myString,0)
        END

        If len(@myString) > 0
            INSERT INTO @ReturnTable (item) VALUES (@myString)

    RETURN 
END
