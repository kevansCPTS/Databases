CREATE procedure [dbo].[up_pprGenFeeMgmtRec] --'PETZ02',43117 , 0
    @account                varchar(8)
,   @userId                 int
,   @efin                   int
as

declare @wTok               char(32)
declare @feeVersion         char(32)
declare @ppr                bit
declare @mrXml              varchar(4000)
declare @pXml               varchar(4000)
declare @errstr             nvarchar(2048)
declare @season             smallint
declare @prod_cd            varchar(4)
declare @seqNum             int



declare @wcTable            table(
    walletToken                     char(32)
,   account                         varchar(8)
,   userId                          int
,   efin                            int 
,   typeId                          tinyint
,   statusId                        tinyint
,   currentBalance                  money
,   errStatus                       tinyint
,   errDesc                         varchar(4000)
)

    set nocount on

    set @season = '20' + right(db_name(),2)
 

    -- Create a new wallet for the account/user or, if exists - return the token.
    insert @wcTable
        exec dbCrosslinkGlobal.dbo.up_walletCreate
            @account = @account        
        ,   @efin = @efin 
        ,   @userId = @userId 
        ,   @season = @season
        ,   @typeId = 10
        ,   @minBalance = 100
        ,   @reloadAmount = 500
        ,   @walletToken = @wTok output

    if @wTok is null
        begin
            set @errstr = 'A wallet was not created or identified for the suplied account, efin, user and wallet type combination'      
            raiserror(@errstr,11,1)                   
            return
        end
    
    if not exists(
                    select 
                        wp.walletId
                    from
                        dbCrosslinkGlobal.dbo.tblWalletProgram wp join dbCrosslinkGlobal.dbo.tblWallet w on wp.walletId = w.walletId
                            and w.walletToken = @wTok
                            and w.statusId = 10
                            and wp.programId = 10
                            and wp.statusId = 10        
                 )
        begin
            set @errstr = 'No active wallet or active wallet program for PPR was found for the specified wallet information.'      
            raiserror(@errstr,11,1)                   
            return
        end  

    -- Bail if there is no found PPR product code.

    if not exists (
                    select
                        pl.ProductCode
                    from
                        dbCrosslinkGlobal.dbo.tblProductLicense pl
                    where
                        pl.Account = @account
                        and pl.UserId = @userId
                        and pl.Season = @season
                        and pl.ProductCode in('PP10','PP1X','PPC1'/*,'PPCX'*/,'PPXA','BUSU','BUSX')
                        and StatusId = 1
                   )
        begin
            set @errstr = 'No active PPR product assignment found for provided account, userId and season.'      
            raiserror(@errstr,11,1)                   
            return
        end  

    -- Generate a unique identifier for the new fee version mgmt record.
    set @feeVersion = replace(convert(varchar(36),newid()),'-','')

    /*
    BUSU – CrossLink Business (Unlimited)
    PP10 – CrossLink PPR 1040
    PP1X – CrossLink PPR 1040 w/Business
    PPC1 – CrossLink Online PPR 1040
    PPCX – CrossLink Online PPR w/Business
    PPXA – CrossLink Business PPR Add-on
    */

    -- Build the XML AuthCode Fee record.
    set @mrXml = '<xmldata><cmnd>AuthCode</cmnd>'
        + case when @efin > 0 then '<efin>' + convert(varchar(10),@efin) + '</efin>' else '' end
        + '<WALT>' + @wTok +  '</WALT>'
        + '<PPRG>' + @feeVersion + '</PPRG>'


    -- Get the PPR package product code for this account and userId combination.
    declare curPpr cursor fast_forward for
        select
            pl.ProductCode
        from
            dbCrosslinkGlobal.dbo.tblProductLicense pl
        where
            pl.Account = @account
            and pl.UserId = @userId
            and pl.Season = @season
            and pl.ProductCode in('PP10','PP1X','PPC1'/*,'PPCX'*/,'PPXA','BUSU','BUSX')
            and StatusId = 1
    
    open curPpr
    fetch next from curPpr into @prod_cd

    while @@fetch_status = 0
        begin
            select 
                @pXml = case @prod_cd 
                            when 'BUSU' then '<PPRB>UNLIMIT</PPRB>'
                            when 'PP10' then '<PPRI>PP10</PPRI>'
                            when 'PP1X' then '<PPRI>PP1X</PPRI>'
                            when 'PPC1' then '<PPRI>PPC1</PPRI>'
                            when 'PPXA' then '<PPRB>PPC1</PPRB>'
                            when 'BUSX' then '<PPRB>BUSX</PPRB>'
                            else ''
                        end
 
                    + '<PPIF>' + convert(varchar(10),convert(int,isnull(bf.fedBaseFee,0) * 100)) + '</PPIF>'
                    + '<PPIS>' + convert(varchar(10),convert(int,isnull(bf.stateBaseFee,0) * 100)) + '</PPIS>'

                    + '<PPIA>' + convert(varchar(10),convert(int,isnull(mu.fedMarkUp,0) * 100)) + '</PPIA>'
                    + '<PPIB>' + convert(varchar(10),convert(int,isnull(mu.stateMarkUp,0) * 100)) + '</PPIB>'

                    + '<PPIC>' + convert(varchar(10),convert(int,isnull(fa.feeAmount,0))) + '</PPIC>'
                    + '<PPIE>' + convert(varchar(10),convert(int,isnull(sa.feeAmount,0))) + '</PPIE>'
                    --+ '<PPID>' + convert(varchar(10),convert(int,isnull(sa.feeAmount,0))) + '</PPID>'

                    + '<PPBF>' + convert(varchar(10),convert(int,isnull(bf.busFedBaseFee,0) * 100)) + '</PPBF>'
                    + '<PPBS>' + convert(varchar(10),convert(int,isnull(bf.busStateBaseFee,0) * 100)) + '</PPBS>'

                    + '<PPBA>' + convert(varchar(10),convert(int,isnull(mu.busFedMarkUp,0) * 100)) + '</PPBA>'
                    + '<PPBB>' + convert(varchar(10),convert(int,isnull(mu.busStateMarkUp,0) * 100)) + '</PPBB>'

                    + '<PPBC>' + convert(varchar(10),convert(int,isnull(bfa.feeAmount,0))) + '</PPBC>'
                    + '<PPBD>' + convert(varchar(10),convert(int,isnull(bsa.feeAmount,0))) + '</PPBD>'

            from
                /* 
                dbo.tblPPRBaseFee bf left join dbo.tblPPRFeeMarkUp mu on bf.prod_cd = mu.prod_cd
                    and bf.prod_cd = @prod_cd
                    and mu.account = @account
                    and mu.userId = @userId
                    and mu.efin = @efin
                */
                (
                    select 
                        bf1.prod_cd
                    ,   bf1.fedBaseFee
                    ,   bf1.stateBaseFee
                    ,   bf1.busFedBaseFee
                    ,   bf1.busStateBaseFee
                    from 
                        dbo.tblPPRBaseFee bf1
                    where
                        bf1.prod_cd = @prod_cd
                ) bf left join (
                                    select
                                        mu1.account
                                    ,   mu1.userId
                                    ,   mu1.efin
                                    ,   mu1.prod_cd
                                    ,   mu1.fedMarkUp
                                    ,   mu1.stateMarkUp
                                    ,   mu1.busFedMarkUp
                                    ,   mu1.busStateMarkUp
                                    from
                                        dbo.tblPPRFeeMarkUp mu1
                                    where
                                        mu1.account = @account
                                        and mu1.userId = @userId 
                                        and mu1.efin = @efin
                                        and mu1.prod_cd = @prod_cd
                                ) mu on bf.prod_cd = mu.prod_cd
                    and bf.prod_cd = @prod_cd
                    and mu.account = @account
                    and mu.userId = @userId
                    and mu.efin = @efin

                left join dbo.tblFeeTier fa on mu.fedMarkUp * 100 between isnull(fa.minVal,0) and isnull(fa.maxVal,9999999)
                        and fa.feeType = 50
                        and fa.account = 'DEFAULT'
                        and fa.active = 1
                left join dbo.tblFeeTier sa on mu.stateMarkUp * 100 between isnull(sa.minVal,0) and isnull(sa.maxVal,9999999)
                        and sa.feeType = 50
                        and sa.account = 'DEFAULT'
                        and sa.active = 1
                left join dbo.tblFeeTier bfa on mu.busFedMarkUp * 100 between isnull(bfa.minVal,0) and isnull(bfa.maxVal,9999999)
                        and bfa.feeType = 50
                        and bfa.account = 'DEFAULT'
                        and bfa.active = 1
                left join dbo.tblFeeTier bsa on mu.busStateMarkUp * 100 between isnull(bsa.minVal,0) and isnull(bsa.maxVal,9999999)
                        and bsa.feeType = 50
                        and bsa.account = 'DEFAULT'
                        and bsa.active = 1



            set @mrXml = @mrXml + @pXml

            fetch next from curPpr into @prod_cd
        end

    close curPpr
    deallocate curPpr

    set @mrXml = @mrXml + '</xmldata>'
    
    -- Insert the PPR entry in the tblMgmt table.

    -- Insert the launch record if it does not exist
    insert dbo.tblMgmt(
        [delivered]
    ,   [userid]
    ,   [seqno]
    ,   [xmldata]
    )
        select
            a.[delivered]
        ,   a.[userId]
        ,   a.[seqno]
        ,   a.[xmldata]
        from
            (
                select
                    ' ' [delivered]
                ,   @userId [userId]
                ,   1 [seqno]
                ,   '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>' [xmldata]

            ) a left join dbo.tblMgmt m on a.[userId] = m.[userId]
                and m.[seqno] = 1
        where
            m.[seqno] is null


    -- Insert the new Mgmt record for the updated fees
    select
        @seqNum = a.seqno + 1 
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

    if @seqNum is null
        set @seqNum = 1


    insert dbo.tblMgmt(
        [delivered]
    ,   [userid]
    ,   [seqno]
    ,   [xmldata]
    )
        select
            ' ' [delivered]
        ,   @userId [userid]
        ,   @seqNum [seqno]
        ,   @mrXml [xmldata]


    -- Update the current fee version in the wallet program table.
    if @@rowcount = 1    
        update wp   
            set wp.feeVersion = @feeVersion
        from
            dbCrosslinkGlobal.dbo.tblWalletProgram wp join dbCrosslinkGlobal.dbo.tblWallet w on wp.walletId = w.walletId
                and w.walletToken = @wTok
                and wp.programId = 10
        




















