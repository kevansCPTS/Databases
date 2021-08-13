
CREATE FUNCTION [dbo].[udf_get_tblTaxmast_FullyFundedDate] (
    @ral_flag           char(1)
,   @pei_prot_fee       int
,   @req_cadr_fee       int
,   @tran_pay_amt       int
,   @req_tech_fee       int
,   @pei_tran_fee       int
,   @ero_tran_fee       int
,   @prot_pay_amt       int
,   @cadr_pay_amt       int
,   @fee_pay_amt        int

,   @tran_pay_date date
,   @cadr_pay_date date
,   @prot_pay_date date
,   @fee_pay_date date  

)
RETURNS 
    date
With 
    Schemabinding
as
    begin
        declare @ffunded bit
        declare @ffdate date

        select @ffunded = case 
                                when @ral_flag = 5 then 
                                    case 
                                        when case 
                                                when @ral_flag = 5 and (@req_tech_fee + @pei_tran_fee + @ero_tran_fee > 0 or @fee_pay_amt > 0) then 1 else 0 end
                                                    + case when @pei_prot_fee > 0 then 1 else 0 end
                                                    + case when @req_cadr_fee > 0 then 1 else 0 end
                                                    - case when @ral_flag = 5 and (@req_tech_fee + @pei_tran_fee + @ero_tran_fee > 0 or @fee_pay_amt > 0) and @tran_pay_amt >= @req_tech_fee + @pei_tran_fee + @ero_tran_fee then 1 else 0 end 
                                                    - case when @pei_prot_fee > 0 and @prot_pay_amt >= @pei_prot_fee then 1 else 0 end
                                                    - case when @req_cadr_fee > 0 and @cadr_pay_amt >= @req_cadr_fee then 1 else 0 end
                                                        = 0 then 1 
                                                else 0
                                             end 
                                else 0
                            end

        if @ffunded = 1
            select
                @ffdate = isnull(max(a.ffdate),@fee_pay_date)
            from
                (
                select
                    @tran_pay_date ffdate
                union select
                    @cadr_pay_date ffdate
                union select
                    @prot_pay_date ffdate
                ) a

        return @ffdate
  

    end
