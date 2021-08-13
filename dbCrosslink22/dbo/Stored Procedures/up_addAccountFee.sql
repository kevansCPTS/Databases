
CREATE procedure [dbo].[up_addAccountFee] 
    @feeTypeid      int
,   @account        varchar(8)
,   @feeAmount      int             
,   @minVal         int         = null
,   @maxVal         int         = null    
as

declare @errstr     varchar(255)
declare @tierSeq    tinyint
declare @maxTierSeq  tinyint

    set nocount on

    if @minVal is null
        set @minVal = 0
    
    --if @maxVal is null
    --    set @maxVal = @minVal

    /*
    if exists(select 
                ft.feeAmount 
              from 
                dbo.tblFeeTier ft 
              where 
                ft.feeType = @feeTypeid 
                and ft.account = @account
                and ft.minVal = @minVal
                and ft.maxVal = @maxVal
                and ft.active = 1)
        begin
            set @errstr = 'There is already an active fee defined for the provided account (' + @account + ') and tier levels (between ' + convert(varchar(25),@minVal) + ' and ' + convert(varchar(25),@maxVal) + ').'      
            raiserror(@errstr,11,1)                   
            return
        end              

    select
        @maxTierSeq = ft.tierSeq
    from
        dbo.tblFeeTier ft
    where
        ft.feeType = @feeTypeid 
        and ft.account = @account
        and ft.active = 1
        
    if @maxTierSeq is null
        set @tierSeq = 1
    else
        set @tierSeq = @maxTierSeq + 1
    */

    if exists(select 
                ft.feeAmount 
              from 
                dbo.tblFeeTier ft 
              where 
                ft.feeType = @feeTypeid 
                and ft.account = @account
                and ft.minVal = @minVal
                and isnull(ft.maxVal,99999999) = isnull(@maxVal,99999999)
                and ft.active = 1)
        update ft
            set ft.feeAmount = @feeAmount
        ,   ft.modifyDate = getdate()
        from
            dbo.tblFeeTier ft
        where
            ft.feeType = @feeTypeid 
            and ft.account = @account
            and ft.minVal = @minVal
            and isnull(ft.maxVal,99999999) = isnull(@maxVal,99999999)
            and ft.active = 1                
    else
        begin
            
            select
                @maxTierSeq = ft.tierSeq
            from
                dbo.tblFeeTier ft
            where
                ft.feeType = @feeTypeid 
                and ft.account = @account
                and ft.active = 1
        
            if @maxTierSeq is null
                set @tierSeq = 1
            else
                set @tierSeq = @maxTierSeq + 1

            insert dbo.tblFeeTier
                select
                    @feeTypeid
                ,   @account
                ,   @tierSeq
                ,   @minVal
                ,   @maxVal
                ,   @feeAmount
                ,   1 
                ,   getdate()
                ,   getdate()

        end
