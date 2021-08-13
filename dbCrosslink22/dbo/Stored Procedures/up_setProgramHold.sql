

CREATE procedure [dbo].[up_setProgramHold]
    @account varchar(8)
,   @userId int
,   @efin int
,   @programTag varchar(4)
,   @holdStat bit
as

declare @mrXml varchar(1000)
declare @errstr nvarchar(2048)
declare @success bit

declare @mrUserId int

    set nocount on

    set @success = 0

    update ph
        set ph.holdStat = @holdStat
    ,   ph.updateDate = getdate()
    from
        dbo.tblProgramHold ph
    where
        ph.account = @account
        and ph.userId = @userId
        and ph.efin = @efin
        and ph.programTag = @programTag

    if @@rowcount = 0
        begin
            insert dbo.tblProgramHold(
                account
            ,   userId
            ,   efin
            ,   programTag
            ,   holdStat
            ,   createDate
            ,   updateDate
            )
                select
                    @account
                ,   @userId
                ,   @efin
                ,   @programTag
                ,   @holdStat
                ,   getdate()
                ,   getDate()

            if @@rowcount = 1
                set @success = 1
        end
    else
        set @success = 1


    if @userId = 0 or (@userId > 500000 and @efin = 0)
        update ph
            set ph.holdStat = @holdStat
        ,   ph.updateDate = getdate()
        from
            dbo.tblProgramHold ph
        where
            ph.account = @account
            and ph.userId = case when @userId = 0 then ph.userId else @userId end
            and ph.efin = case when @efin = 0 and @userId > 500000 then ph.efin else @efin end
            and ph.programTag = @programTag
       


    if @success = 0 
		begin
            if @userId < 500000
			    set @errstr = 'Failed to update the hold status for the specified user Id (' + convert(nvarchar(25),@userId) + '). Please try again.' 
            else 
			    set @errstr = 'Failed to update the hold status for the specified user Id (' + convert(nvarchar(25),@userId) + ') and efin ('+ convert(nvarchar(25),@efin) + '). Please try again.' 

			raiserror(@errstr,11,1)                   
			return
		end	

        set @mrXml = '<xmldata><cmnd>AuthCode</cmnd><' + @programTag + '>' + case @holdStat when 1 then 'X' else '' end + '</' + @programTag + '></xmldata>'


    declare curMRec cursor fast_forward for
        select 
            u.[user_id] userId
        ,   0 efin
        from 
            dbCrosslinkGlobal .dbo.tblUser u 
        where
            u.account = @account
            and u.[user_id] = case when @userId = 0 then u.[user_id] else @userId end

    open curMRec
    fetch next from curMRec into @mrUserId

    while @@fetch_status = 0
        begin
            insert dbo.tblMgmt(
                [delivered]
            ,   [userid]
            ,   [seqno]
            ,   [xmldata]
            )
            select
                ' ' [delivered]
            ,   a.[user_id] [userid]
            ,   a.seqno + 1 [seqno]
            ,   @mrXml [xmldata]   
            from
                (
                    select
                        m.userid [user_id] 
                    ,   m.seqno
                    ,   row_number() over ( partition by m.userid order by m.seqno desc) rowNum
                    from
                        dbo.tblMgmt m
                    where
                        m.userid = @userId
                ) a
            where
                a.rowNum = 1

            if @@rowcount = 0
		        begin
                    if @userId < 500000
			        set @errstr = 'Failed to update the hold status for the specified user Id (' + convert(nvarchar(25),@userId) + '). Please try again.' 
                    else 
			        set @errstr = 'Failed to update the hold status for the specified user Id (' + convert(nvarchar(25),@userId) + ') and efin ('+ convert(nvarchar(25),@efin) + '). Please try again.' 

			        raiserror(@errstr,11,1)                   
			        return
		        end	

            fetch next from curMRec into @mrUserId
        end

    close curMRec
    deallocate curMRec


    -- Return the current hold status record
    select
        ph.account
    ,   ph.userId 
    ,   ph.efin 
    ,   ph.programTag       
    ,   ph.holdStat      
    ,   ph.createDate     
    ,   ph.updateDate    
    from
        dbo.tblProgramHold ph 
    where
        ph.account = @account
        and ph.userId = @userId
        and ph.efin = @efin
        and ph.programTag = @programTag

