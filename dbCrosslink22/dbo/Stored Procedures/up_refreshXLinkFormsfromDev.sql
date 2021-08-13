CREATE procedure [dbo].[up_refreshXLinkFormsfromDev]
as

declare @sName varchar(25)

set nocount on

    set @sName = @@servername



    -- if this is being run on QA, refresh QA from Dev
    if @sName = 'QADBA'
        begin
            -- Remove old entries
            delete from QADBA.dbCrosslink14.dbo.tblXlinkForms

            -- Insert data into QA table from DEV 
            insert QADBA.dbCrosslink14.dbo.tblXlinkForms ( 
                [state] 
            ,   form_type 
            ,   form_cd 
            ,   form_short_name 
            ,   form_long_name 
            ,   form_group
            ) 
                select 
                    xf.[state] 
                ,   xf.form_type 
                ,   xf.form_cd 
                ,   xf.form_short_name 
                ,   xf.form_long_name 
                ,   xf.form_group
                from 
                    DEVDBA.dbCrosslink14.dbo.tblXlinkForms xf 
        end      


    -- if this is being run on PROD, refresh PROD from QA
    if @sName = 'PRODDBA'
        begin
            -- Remove old entries
            delete from PRODDBA.dbCrosslink14.dbo.tblXlinkForms

            -- Insert data into PROD table from QA 
            insert PRODDBA.dbCrosslink14.dbo.tblXlinkForms ( 
                [state] 
            ,   form_type 
            ,   form_cd 
            ,   form_short_name 
            ,   form_long_name 
            ,   form_group
            ) 
                select 
                    xf.[state] 
                ,   xf.form_type 
                ,   xf.form_cd 
                ,   xf.form_short_name 
                ,   xf.form_long_name 
                ,   xf.form_group
                from 
                    QADBA.dbCrosslink14.dbo.tblXlinkForms xf 
        end  


/*
    -- Clear QA table 
    delete from QADB.dbCrosslink14.dbo.tblXlinkForms 

    -- Insert data into QA table from DEV 
    insert QADB.dbCrosslink14.dbo.tblXlinkForms ( 
        [state] 
    ,   form_type 
    ,   form_cd 
    ,   form_short_name 
    ,   form_long_name 
    ,   form_group
    ) 
        select 
            xf.[state] 
        ,   xf.form_type 
        ,   xf.form_cd 
        ,   xf.form_short_name 
        ,   xf.form_long_name 
        ,   xf.form_group
        from 
            DEVDBA.dbCrosslink14.dbo.tblXlinkForms xf 

    -- Clear PROD table 
    delete from PRODDBA.dbCrosslink14.dbo.tblXlinkForms 

    -- Insert data into PROD table from DEV 
    insert PRODDBA.dbCrosslink14.dbo.tblXlinkForms ( 
        [state] 
    ,   form_type 
    ,   form_cd 
    ,   form_short_name 
    ,   form_long_name 
    ,   form_group
    ) 
        select 
            xf.[state] 
        ,   xf.form_type 
        ,   xf.form_cd 
        ,   xf.form_short_name 
        ,   xf.form_long_name 
        ,   xf.form_group
        from 
            DEVDBA.dbCrosslink14.dbo.tblXlinkForms xf 

*/

