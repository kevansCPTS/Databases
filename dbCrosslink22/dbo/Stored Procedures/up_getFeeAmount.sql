
CREATE procedure [dbo].[up_getFeeAmount] --10,'DEFAULT', 6002 --30, 'CTTS', null
    @feeTypeid      int
,   @account        varchar(8)
,   @value          int             = null
as

    set nocount on
    
    if @value is null
        set @value = 0
      
    select 
        --@account account
        ft.feeAmount
    from 
        dbo.tblFeeTier ft 
    where
        ft.feeType = @feeTypeId
        and ft.account = @account
        and ft.active = 1
        and @value between isnull(ft.minVal,0) and isnull(ft.maxVal,99999999)
