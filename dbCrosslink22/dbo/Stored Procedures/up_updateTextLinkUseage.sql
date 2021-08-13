
CREATE procedure [dbo].[up_updateTextLinkUseage]
as

set nocount on

    -- Update existing user counts
    update tu
        set tu.MapEntryTotal = a.MapEntryTotal
    from
        dbCrosslinkGlobal.dbo.tblTextLinkUsage tu join (
                                                        select
                                                            tm.source_user_id UserId
                                                        ,   convert(smallint,'20' + right(db_name(),2)) Season
                                                        ,   count(*) MapEntryTotal
                                                        from
                                                            dbo.tblTextLinkMap tm 
                                                        group by
                                                            tm.source_user_id
                                                        ) a on tu.UserId = a.UserId
            and tu.Season = a.Season
            and tu.MapEntryTotal != a.MapEntryTotal

    -- Add new user counts
    insert dbCrosslinkGlobal.dbo.tblTextLinkUsage(
        UserId
    ,   Season
    ,   MapEntryTotal
    )
        select
            tm.source_user_id UserId
        ,   convert(smallint,'20' + right(db_name(),2)) Season
        ,   count(*) MapEntryTotal
        from
            dbo.tblTextLinkMap tm left join dbCrosslinkGlobal.dbo.tblTextLinkUsage tu on tm.source_user_id = tu.UserId 
                and tu.Season = convert(smallint,'20' + right(db_name(),2))
        where
            tu.UserId is null
            and tm.source_user_id is not null
        group by
            tm.source_user_id


