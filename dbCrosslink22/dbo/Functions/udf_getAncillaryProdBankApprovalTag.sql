

CREATE function [dbo].[udf_getAncillaryProdBankApprovalTag]
(
    @aprodId    int
)
returns 
    char(5)
as
    begin

        declare @tag char(5)

        select
            @tag = max(case when apba.bankId = 'R' and apba.peiBankHasApproval = 1 then '1' else '0' end) --republic
        +   max(case when apba.bankId in('W','S')  and apba.peiBankHasApproval = 1 then '1' else '0' end) --worldTpg
        +   max(case when apba.bankId = 'F' and apba.peiBankHasApproval = 1 then '1' else '0' end) --refundo
        +   max(case when apba.bankId = 'V' and apba.peiBankHasApproval = 1 then '1' else '0' end) --refundAdv
        +   '0' --futureUse
        from 
            dbo.tblAncillaryProductBankApproval apba
        where 
            apba.aprodId = @aprodId
        group by
            apba.aprodId
        
        if @tag is null
            set @tag = '00000'
    
        return @tag

    
    end








