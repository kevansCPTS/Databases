create procedure [ke_pprGenFeeMgmtRec_ver1] --'BRASUN',60392,0
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
declare @sSeason            char(2)
declare @sqlstr             nvarchar(max)

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
    if @prod_cd is null
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
 
                    + '<PPIF>' + convert(varchar(10),isnull(bf.fedBaseFee,0) * 100) + '</PPIF>'
                    + '<PPIS>' + convert(varchar(10),isnull(bf.stateBaseFee,0) * 100) + '</PPIS>'
/*
                    + '<PPIA>' + convert(varchar(10),isnull(,0) * 100) + '</PPIA>'
                    + '<PPIB>' + convert(varchar(10),isnull(,0) * 100) + '</PPIB>'

                    + '<PPIC>' + convert(varchar(10),isnull(,0) * 100) + '</PPIC>'
                    + '<PPID>' + convert(varchar(10),isnull(,0) * 100) + '</PPID>'
*/
                    + '<PPBF>' + convert(varchar(10),isnull(bf.busFedBaseFee,0) * 100) + '</PPBF>'
                    + '<PPBS>' + convert(varchar(10),isnull(bf.busStateBaseFee,0) * 100) + '</PPBS>'
/*
                    + '<PPBA>' + convert(varchar(10),isnull(,0) * 100) + '</PPBA>'
                    + '<PPBB>' + convert(varchar(10),isnull(,0) * 100) + '</PPBB>'

                    + '<PPBC>' + convert(varchar(10),isnull(,0) * 100) + '</PPBC>'
                    + '<PPBD>' + convert(varchar(10),isnull(,0) * 100) + '</PPBD>'
*/
            from 
               dbo.tblPPRBaseFee bf
            where
                bf.prod_cd = @prod_cd

            set @mrXml = @mrXml + @pXml

            fetch next from curPpr into @prod_cd
        end

    close curPpr
    deallocate curPpr


    
    -- Insert the PPR entry in the tblMgmt table.

    -- Set the season string
    set @sSeason = right(convert(char(4),@season),2)


    -- Insert the launch record if it does not exist
    set @sqlstr = 'insert dbCrosslink' + right(@sSeason,2) + '.dbo.tblMgmt(
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
                    '' '' [delivered]
                ,   ' + convert(varchar(25),@userId) + ' [userId]
                ,   1 [seqno]
                ,   ''<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'' [xmldata]

            ) a left join dbCrosslink' + right(@sSeason,2) + '.dbo.tblMgmt m on a.[userId] = m.[userId]
                and m.[seqno] = 1
        where
            m.[seqno] is null'
    exec sp_executesql @sqlstr


    set @sqlstr = '
    declare @seqNum int


    select
        @seqNum = a.seqno + 1 
    from
        (
            select
                m.userid [user_id] 
            ,   m.seqno
            ,   row_number() over ( partition by m.userid order by m.seqno desc) rowNum
            from
                dbCrosslink' + right(@sSeason,2) + '.dbo.tblMgmt m
            where
                m.userid = ' + convert(varchar(25),@userId) + '
        ) a
    where
        a.rowNum = 1

    if @seqNum is null
        set @seqNum = 1

    insert dbCrosslink' + right(@sSeason,2) + '.dbo.tblMgmt(
        [delivered]
    ,   [userid]
    ,   [seqno]
    ,   [xmldata]
    )
        select
            '' '' [delivered]
        ,   ' + convert(varchar(25),@userId) + ' [userid]
        ,   @seqNum [seqno]
        ,   ''' + @mrXml + ''' [xmldata]'


    exec sp_executesql @sqlstr


    -- Update the current fee version in the wallet program table.
    update wp   
        set wp.feeVersion = @feeVersion
    from
        dbCrosslinkGlobal.dbo.tblWalletProgram wp join dbCrosslinkGlobal.dbo.tblWallet w on wp.walletId = w.walletId
            and w.walletToken = @wTok
            and wp.programId = 10
        




















