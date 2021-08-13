
CREATE procedure ke_getEFINValidFileName --'d:\SQLDATA\IRS\efinValid\archive\toIRS\'
    @archivePath        varchar(1000)
,   @fname              char(34) output
AS

declare @fileMask           varchar(40)
declare @dirTree table (
    id                      int IDENTITY(1,1)
,   fname                   nvarchar(512)
,   depth                   int
,   isfile                  bit
)

    set nocount on

    set @fileMask = 'PETZET_EFIN_VALID________' + replace(convert(char(10),getdate(),101),'/','') + '.txt'

    insert @dirTree
        exec master.dbo.xp_DirTree @archivePath,1,1

    if exists(select fname from @dirTree where isfile = 1 and SUBSTRING(fname,23,8) = replace(convert(char(10),getdate(),101),'/',''))
        select
            @fname = 'PETZET_EFIN_VALID_' + replicate('0', 3 - datalength((convert(varchar(3),max(convert(smallint,SUBSTRING(fname,19,3))) + 1)))) + (convert(varchar(3),max(convert(smallint,SUBSTRING(fname,19,3))) + 1)) + '_' + replace(convert(char(10),getdate(),101),'/','') + '.txt'
        from 
            @dirTree
        where
            isfile = 1
            and SUBSTRING(fname,23,8) = replace(convert(char(10),getdate(),101),'/','')
    else
        set @fname = 'PETZET_EFIN_VALID_001_' + replace(convert(char(10),getdate(),101),'/','') + '.txt'

