CREATE procedure [dbo].[up_getFranchiseUserStatus] --22418
    @userId     int
as 

declare @uid int
declare @dbName varchar(25)
declare @sqlstr nvarchar(2000)
declare @pdef nvarchar(1000)
declare @active bit

declare @output table(
    UserId  int
,   Season  int     
,   Active  bit
)

set nocount on

    declare curDb cursor fast_forward for
        select 
            sdb.[Name] dbName 
        from 
            sys.databases sdb 
        where 
            sdb.name like 'dbCrosslink%' 
            and isnumeric(right(name,2)) = 1
            --and sdb.name != 'dbCrosslink18'
            --and sdb.name != 'dbCrosslink13'
            and sdb.name != 'dbCrosslink11'


    open curDb
    fetch next from curDb into @dbName

    set @sqlstr = ''

    while @@fetch_status = 0
        begin
            
            set @uid = null
            set @sqlstr = N'select @userId_season = UserId from ' + @dbName + '.dbo.FranchiseOwner where UserId = ' + convert(varchar(25),@userId) + '; set @userId_season = @@rowcount' 
            set @pdef = N'@userId_season int OUTPUT'
            exec sp_executesql @sqlstr,@pdef, @userId_season = @uid OUTPUT

            set @active = case when @uid = 0 then 0 else 1 end
            
            insert @output
                select @userId, convert(int,'20' + right(@dbName,2)), @active


            fetch next from curDb into @dbName
        end 

    close curDb
    deallocate curDb



    select
        o.UserId
    ,   o.Season
    ,   o.Active      
    from
        @output o   
    order by
        o.UserId
    ,   o.Season
     


--grant exec on up_getFranchiseUserStatus to public


/*
select * from dbCrosslink11.dbo.FranchiseOwner where UserId = 22418
select * from dbCrosslink12.dbo.FranchiseOwner where UserId = 22418
select * from dbCrosslink13.dbo.FranchiseOwner where UserId = 22418
select * from dbCrosslink14.dbo.FranchiseOwner where UserId = 22418
select * from dbCrosslink15.dbo.FranchiseOwner where UserId = 22418
*/

