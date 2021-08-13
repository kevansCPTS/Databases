-- =============================================
-- Author:		Josh Daniel
-- Create date: 01/13/2011
-- Description:	Purpose is to pull RA rolls from taxmast
--				and insert into TransmitterInvoice so that we
--				can send out to RA
--     01/30/2011 changed this thing around to cap ERO tran fee at a 
--				  set threshold and record the difference
--     02/11/2011 changed to include bank state of B and D as well
-- =============================================
CREATE PROCEDURE [dbo].[spTransmitterInvoice]
AS
BEGIN
--Declare what we need
Declare @efin int
Declare @pssn int
Declare @eroMarkup int
Declare @markupThreshhold int

--This is the max ero markup we can send to RA
Set @markupThreshhold=2800

--delete from some tables
delete from TransmitterInvoiceMarkup
--Delete everything not processed yet
delete from TransmitterInvoice 
		where delivered=0 and responded=0 and paid=0 


--First write to the break down table
	SELECT  
	TM.pssn,
	count(*) as count,
	TM.efin,
	
	sum(
	case when roll_tran_pay_amt > 0 or roll_sb_pay_amt > 0 then
		case when (roll_tran_pay_amt-(req_tech_fee+pei_tran_fee+ero_tran_fee)) > 0 then
			1
		else
			0
		end
	else
		case when (pei_prot_fee > 0) then
			1
		else
			0
		end
	end
	) as protPlusCount,

	sum(
	case when roll_tran_pay_amt > 0 or roll_sb_pay_amt > 0 then
	1
	else
	0
	end) as paid,

	sum(
	case when roll_tran_pay_amt > 0 or roll_sb_pay_amt > 0 then
		roll_tran_pay_amt-(req_tech_fee+ero_tran_fee+pei_prot_fee)
	else
		pei_tran_fee
	end) as peitranfee,
	
	sum(
	case when roll_tran_pay_amt > 0 or roll_sb_pay_amt > 0 then
		roll_tran_pay_amt-(req_tech_fee+pei_tran_fee+pei_prot_fee)
	else
		ero_tran_fee
	end) as erotranfee,
	
	sum(
	case when roll_tran_pay_amt > 0 or roll_sb_pay_amt > 0 then
		roll_sb_pay_amt
	else
		sb_prep_fee
	end) as sbprepfee,
	
	sum(
	case when roll_tran_pay_amt > 0 or roll_sb_pay_amt > 0 then
		roll_tran_pay_amt-(req_tech_fee+pei_tran_fee+ero_tran_fee)
	else
		pei_prot_fee
	end) as peiprotfee,
		
	sum(
	case when roll_tran_pay_amt > 0 or roll_sb_pay_amt > 0 then
		req_tech_fee
	else
		req_tech_fee
	end) as reqtechfee
INTO #tempBreakdown

		FROM tbltaxmast TM with (nolock)
		WHERE 
			bank_stat in ('A','B','D') 
			AND roll = 'Y'
			AND ral_flag in ('3', '5', '6')
			AND IsNull(tm.bank_id, ' ') = 'V'

group by TM.pssn, TM.efin

--select * from #tempBreakdown

--Make another Copy
select *  INTO #tempBreakdownCopy from #tempBreakdown


Select Top 1 @pssn = pssn From #tempBreakdown

--Next loop over the breakdown table and check for ero markup over $28(@markupThreshhold)
While (Select Count(*) From #tempBreakdown) > 0
Begin
	 Select Top 1 @pssn = pssn,@efin=efin, @eroMarkup=erotranfee From #tempBreakdown
	
	if(isNull(@eroMarkup,0) > @markupThreshhold)
	begin
		--update the copy table to a lower ERO markup amount
		--add a row to our TransmitterInvoiceEroMarkup so that we can bill ERO later for difference
		update #tempBreakdownCopy set erotranfee=@markupThreshhold where pssn=@pssn
		insert into TransmitterInvoiceMarkup (efin,pssn, MarkupDifference) values(@efin,@pssn,@eroMarkup-@markupThreshhold)
	end
	
	 Delete #tempBreakdown Where pssn = @pssn
End


--Ok now need to group by efin from #tempBreakdownCopy
SELECT  
	count(*) as numberOf,
	sum(protPlusCount) as protPlusCount,
	TM.efin,
	sum(peitranfee + erotranfee+sbprepfee+peiprotfee+reqtechfee) as amount,
	(isNull((select sum(amountDue) from TransmitterInvoice where efin=TM.efin),0)) as invoicedAmount
	INTO #tempCompare FROM #tempBreakdownCopy TM
group by efin

--Next statement is just for debug
select * from #tempCompare where (amount - invoicedAmount) > 0

Select Top 1 @efin = efin From #tempCompare

--get rid of anything that we dont need to invoice
delete from #tempCompare where (amount - invoicedAmount) <= 0

--Loop over remaining
While (Select Count(*) From #tempCompare) > 0
Begin

    Select Top 1 @efin = efin From #tempCompare
    
    Declare @protPlusCountAlready int
	Declare @countAlready int
	Declare @count int
	Declare @amount int
	Declare @protPlusCount int
	select @protPlusCount=protPlusCount,@count=numberOf,@amount=amount from #tempCompare where efin=@efin

	select @countAlready=sum(count) from TransmitterInvoice where efin=@efin
	Set @count = isNull(@count,0) - isNull(@countAlready,0)
	
	select @protPlusCountAlready=sum(protPlusCount) from TransmitterInvoice where efin=@efin
	Set @protPlusCount = isNull(@protPlusCount,0) - isNull(@protPlusCountAlready,0)
	

	Declare @id int
	SELECT @id=IDENT_CURRENT('TransmitterInvoice') + 1

	Declare @difference int

	select @difference = isNull(sum(amountDue),0) from TransmitterInvoice where efin=@efin
	
	--PRINT @difference

   -- select amount from #tempCompare where efin=@efin
	--Here we insert into the invoice table
	Declare @description varchar(150)
	
	if(isNull(@protPlusCount,0) > 0) 
	begin
		Set @description = cast(@count as varchar) + ' EFILE RETURN(S), ' + cast(@protPlusCount as varchar) + ' PROTECTION PLUS'
	end
	else
	begin
		Set @description = cast(@count as varchar) + ' EFILE RETURN(S)'
	end
	
	
	insert into TransmitterInvoice (efin, transmitterEfin, invoiceDate,
										invoiceNumber, amountDue, description,count, protPlusCount)
			values(@efin, 900820, getDate(), cast(1000 + @efin as varchar) + cast(@id as varchar), 
					@amount-@difference, @description, @count,@protPlusCount)

    Delete #tempCompare Where efin = @efin

End



--Do some cleanup
drop table #tempBreakdown
drop table #tempBreakdownCopy
drop table #tempCompare

select * from TransmitterInvoice
	
END


