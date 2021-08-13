CREATE procedure [dbo].[up_getEFINValidationFileData]
as

declare @isids table(
    industrySoftwareID         char(10)    
)

insert @isids values('17005035  ') -- xl-nr
insert @isids values('17005036  ') -- xl
insert @isids values('17005037  ') -- xl-web

insert @isids values('18007072  ')
insert @isids values('18007073  ')
insert @isids values('18007074  ')
insert @isids values('18007075  ')
insert @isids values('18007076  ')
insert @isids values('18007149  ')
insert @isids values('18007151  ')
insert @isids values('18007152  ')
insert @isids values('18007153  ')
insert @isids values('18007154  ')

    set nocount on

    select 
        convert(varchar(6),a.IndustryCode)  IndustryCode                                                                                                       -- 5
    ,   convert(varchar(5),a.StateAgencyCode) StateAgencyCode                                                                                                     -- 4
    ,   convert(varchar(6),a.[Sequence]) [Sequence]                                                                                                          -- 6
    ,   convert(varchar(20),a.TrackingNumber) TrackingNumber                                                                                                      -- 20
    ,   convert(varchar(6),a.efin) efin                                                                                                                -- 6
    ,   convert(varchar(1),a.ResultEfinStatus) ResultEfinStatus                                                                                                    -- 1
    ,   convert(varchar(9),a.EfinOwnerTin) EfinOwnerTin                                                                                                        -- 9
    ,   convert(varchar(1),a.EfinOwnerTinType) EfinOwnerTinType                                                                                                    -- 1
    ,   convert(varchar(50),a.EfinOwnerLegalName) EfinOwnerLegalName                                                                                                  -- 50
    ,   convert(varchar(50),a.EfinOwnerDBAName) EfinOwnerDBAName                                                                                                    -- 50
    ,   convert(varchar(50),a.EfinAddress1) EfinAddress1                                                                                                        -- 50
    ,   convert(varchar(50),a.EfinAddress2) EfinAddress2                                                                                                        -- 50
    ,   convert(varchar(30),a.EfinCity) EfinCity                                                                                                            -- 30
    ,   convert(varchar(20),a.EfinState) EfinState                                                                                                           -- 20
    ,   convert(varchar(10),a.EfinPostal) EfinPostal                                                                                                          -- 10
    ,   convert(varchar(3),a.EfinCountry) EfinCountry                                                                                                         -- 3
    ,   convert(varchar(30),a.EfinContactName) EfinContactName                                                                                                     -- 30
    ,   convert(varchar(20),a.EfinContactPhone) EfinContactPhone                                                                                                    -- 20
    ,   convert(varchar(10),id.industrySoftwareID) industrySoftwareID                                                                                                -- 10
    ,   convert(varchar(16),a.CustomerVendorID) CustomerVendorID                                                                                                    -- 16
    ,   convert(varchar(1),a.IndustryActionFlag) IndustryActionFlag  
    from
        (
            select 
                ev.IndustryCode                                                                                                         -- 5
            ,   '     ' StateAgencyCode                                                                                                 -- 4
            ,   REPLICATE('0',6-datalength(CONVERT(varchar(6),ev.[Sequence]))) + CONVERT(varchar(6),ev.[Sequence]) [Sequence]           -- 6
            ,   ev.TrackingNumber                                                                                                       -- 20
            ,   REPLICATE('0',6-datalength(CONVERT(varchar(6),ev.Efin))) + CONVERT(varchar(6),ev.efin) efin                             -- 6
            ,   ev.ResultEfinStatus                                                                                                     -- 1
            ,   ev.EfinOwnerTin                                                                                                         -- 9
            ,   ev.EfinOwnerTinType                                                                                                     -- 1
            ,   ev.EfinOwnerLegalName                                                                                                   -- 50
            ,   ev.EfinOwnerDBAName                                                                                                     -- 50
            ,   ev.EfinAddress1                                                                                                         -- 50
            ,   ev.EfinAddress2                                                                                                         -- 50
            ,   ev.EfinCity                                                                                                             -- 30
            ,   ev.EfinState                                                                                                            -- 20
            ,   ev.EfinPostal                                                                                                           -- 10
            ,   ev.EfinCountry                                                                                                          -- 3
            ,   ev.EfinContactName                                                                                                      -- 30
            ,   ev.EfinContactPhone                                                                                                     -- 20

            ,   ev.CustomerVendorID                                                                                                     -- 16
            ,   ev.IndustryActionFlag                                                                                                   -- 1
            from
                dbo.tblEFINValidation ev
            where
                isnull(ev.ResultEfinStatus,' ') != 'V'
                --and ev.EFINUpdatedDate >= isnull(ev.SentDate,'20010101')
        ) a cross join @isids id
    order by
        id.industrySoftwareID
    ,   a.efin
