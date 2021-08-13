
create procedure up_addFeePayment
    @pssn               int
,   @bankId             char(1)
,   @tag                char(3)
,   @totalAmount        money
,   @payDate            date
,   @fileDataId         int
,   @paymentAmount      money           output
as

declare @currentPaymentTotal    money
declare @aprodId                int 

    set nocount on

    select
        @paymentAmount = case 
                            when @totalAmount > sum(pt.payAmount) then @totalAmount - sum(pt.payAmount)
                            else 0.00
                         end
    ,   @aprodId = max(ap.aprodId)
    from
        dbo.tblFeePayTransaction pt join dbo.tblAncillaryProduct ap on pt.aprodId = ap.aprodId
            and pt.pssn = @pssn
            and pt.bankId = @bankId
            and ap.tag = @tag
        
    
    if @paymentAmount > 0
        begin
            insert dbo.tblFeePayTransaction
                select
                    @pssn pssn
                ,   @bankId bankId
                ,   @aprodId aprodId
                ,   @paymentAmount payAmount
                ,   @payDate payDate
                ,   @fileDataId fileDataId
        end


    









 

























































































