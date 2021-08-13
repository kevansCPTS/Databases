CREATE procedure [dbo].[up_getStatemastRecord] --400004209
    @pssn       int
as

    set nocount on

    select
        sm.pssn
    ,   sm.state_ack
    ,   sm.state_id
    ,   sm.state_ackd
    ,   sm.state_ralf
	,   sm.state_acky
    ,   tm.bank_id
    ,   convert(money, sm.state_rfnd) state_rfnd
    ,   case 
            when state_ralf = 3 then convert(money, sm.state_rfnd) - isnull(eb.stateadminfee, 0)
            else convert(money, sm.state_rfnd) 
        end	expectedRefund
    from
        dbo.tblStamast sm left join tblTaxmast tm on sm.pssn = tm.pssn
            and sm.[user_id] = tm.[user_id]
        left join dbo.EFINBank eb on tm.bank_id = eb.EFINBankID
    where
        sm.pssn = @pssn
        and sm.subtype = 'SA'