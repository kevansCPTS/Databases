
create procedure [dbo].[up_isLiveUser] --23307
    @userId     int
as

declare @isLiveUser bit

set nocount on

    set @isLiveUser = 0

    if exists(
                select
                    a.*
                from
                    [dbo].[admin] a
                where
                    a.ssn = @userId
                    and a.req_type = 'A'
             )   
        set @isLiveUser = 1

    select
        @isLiveUser IsLiveUser






