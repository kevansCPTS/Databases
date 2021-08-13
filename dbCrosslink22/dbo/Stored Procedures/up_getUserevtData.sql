create procedure up_getUserevtData --'68DA9DAD4A1079233F63A76DAE5A51DE'
    @rtnguid char(32)
as

set nocount on

    
    select
        a.evtguid
    ,   a.pssn
    ,   a.[type]
    ,   a.evtdate
    ,   a.evttime
    ,   a.operator
    ,   a.[site]
    ,   a.userid
    ,   a.rtnguid
    ,   a.details
    ,   a.usertype    
    ,   uet.[Description]
    from
        (
            select 
                ue.evtguid
            ,   ue.pssn
            ,   ue.[type]
            ,   ue.evtdate
            ,   ue.evttime
            ,   ue.operator
            ,   ue.[site]
            ,   ue.userid
            ,   ue.rtnguid
            ,   ue.details
            ,   ue.usertype
            from 
                dbo.userevt ue 
            where
                ue.rtnguid = @rtnguid
        ) a join dbo.UserEventType uet on a.[type] = uet.UserEventTypeCode 
    order by 
        a.evtdate desc
    ,   a.evttime desc


