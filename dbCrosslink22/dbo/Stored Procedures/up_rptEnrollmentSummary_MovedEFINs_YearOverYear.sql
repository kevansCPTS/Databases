
create procedure [dbo].[up_rptEnrollmentSummary_MovedEFINs_YearOverYear]
    @season smallint output
as

create table #efin_move(
    efin            int             PRIMARY KEY
,   userId          int
,   account         varchar(8)
,   userId_py       int
,   account_py      varchar(8)
)

--declare @season     smallint
declare @sqlstr     nvarchar(2000) 

    set nocount on

    set @season = '20' + right(db_name(),2)
    set @sqlstr = 'select
                        ecy.Efin
                    ,   ecy.UserID 
                    ,   ecy.account
                    --,   ecy.selectedBank
                    --,   ecy.efinType
                    ,   epy.UserID UserID_py
                    ,   epy.account account_py
                    from
                        (
                            select 
                                e2.Efin
                            ,   e2.UserID
                            ,   u2.account
                            --,   e2.selectedBank
                            --,   e2.efinType
                            from
                                dbCrosslink' + right(convert(char(4),@season),2) + '.dbo.efin e2 join dbCrosslinkGlobal.dbo.tblUser u2 on e2.UserID = u2.[user_id]
                        ) ecy join (
                                        select 
                                            e1.Efin
                                        ,   e1.UserID
                                        ,   u1.account
                                        from
                                            dbCrosslink' + right(convert(char(4),@season) - 1,2) + '.dbo.efin e1 join dbCrosslinkGlobal.dbo.tblUser u1 on e1.UserID = u1.[user_id]
                                   ) epy on ecy.Efin = epy.Efin
                            and ecy.account != epy.account'
    
    insert #efin_move
        exec sp_executesql @sqlstr


    select
        a.account
    ,   a.LeadExec
    ,   a.UserID
    ,   a.Efin
    ,   a.SelectedBank
    ,   a.Vip
    ,   a.EFINType
    ,   a.RefundAdvantage
    ,   a.RefundAdvantageCode
    ,   a.SBTPG
    ,   a.SBTPGCode
    ,   a.Refundo
    ,   a.RefundoCode
    ,   a.Republic
    ,   a.RepublicCode
    ,   a.SBTPGW
    ,   a.SBTPGWCode
    ,   a.Efiles
    ,   a.Submitted
    ,   a.Funded
    ,   b.account_py
    ,   b.userId_py
    from
        (
            select
                u.account
            ,   le.LeadExec
            ,   e.userId
            ,   e.efin
            ,   bid.bank_name SelectedBank
            ,   case isnull(v.vip_stat,'N') 
                    when 'P' then 'Platinum'
                    when 'Y' then 'VIP'
                    else isnull(c.CustomerSize, '') 
                end Vip
            ,   case e.EFINType 
                    when 'S' then 'Sub' 
                    when 'M' then 'Master'
                    else ''
                end EFINType
            ,   isnull(max(case 
                    when vba.BankID = 'V' then vba.RegisteredDescription
                    else null       
                end),'UnRegistered') RefundAdvantage
            ,   isnull(max(case 
                    when vba.BankID = 'V' then vba.Registered
                    else null       
                end),'U') RefundAdvantageCode
            ,   isnull(max(case 
                    when vba.BankID = 'S' then vba.RegisteredDescription
                    else null       
                end),'UnRegistered') SBTPG
            ,   isnull(max(case 
                    when vba.BankID = 'S' then vba.Registered
                    else null       
                end),'U') SBTPGCode
            ,   isnull(max(case 
                    when vba.BankID = 'F' then vba.RegisteredDescription
                    else null       
                end),'UnRegistered') Refundo
            ,   isnull(max(case 
                    when vba.BankID = 'F' then vba.Registered
                    else null       
                end),'U') RefundoCode
            ,   isnull(max(case 
                    when vba.BankID = 'R' then vba.RegisteredDescription
                    else null       
                end),'UnRegistered') Republic
            ,   isnull(max(case 
                    when vba.BankID = 'R' then vba.Registered
                    else null       
                end),'U') RepublicCode
            ,   isnull(max(case 
                    when vba.BankID = 'W' then vba.RegisteredDescription
                    else null       
                end),'UnRegistered') SBTPGW
            ,   isnull(max(case 
                    when vba.BankID = 'W' then vba.Registered
                    else null       
                end),'U') SBTPGWCode
            ,   fa.Efiles
            ,   fa.Submitted
            ,   fa.Funded
            from 
                dbo.efin e join dbCrosslinkGlobal.dbo.tblUser u on e.userid = u.[user_id] 
                join dbCrosslinkGlobal.dbo.customer c on u.account = c.account
                join dbCrosslinkGlobal.dbo.vwLeadExecutive le on c.account = le.accountcode
                left join dbCrosslinkGlobal.dbo.bank_id bid on e.SelectedBank = bid.bank_id 
                left join (
                                select    
                                    dfa.efin
                                ,   sum(dfa.Efiles) Efiles
                                ,   sum(dfa.SubmittedBankProducts) Submitted
                                ,   sum(dfa.FundedBankProducts) Funded
                                from      
                                    dbcrosslinkglobal.dbo.tblDailyFilingActivity dfa
                                where   
                                    dfa.season = @season - 1 -- per accounting
                                group by 
                                    dfa.efin
                          ) fa on e.efin = fa.efin
                left join dbo.vwLatestBankApplication vba on e.efin = vba.efin 
                left join dbCrosslinkGlobal.dbo.vip v on c.idx = v.idx
            where
                vba.efin is not null
                and vba.Registered != 'U'
            group by
                u.account
            ,   le.LeadExec
            ,   e.userId
            ,   e.efin
            ,   bid.bank_name 
            ,   case isnull(v.vip_stat,'N') 
                    when 'P' then 'Platinum'
                    when 'Y' then 'VIP'
                    else isnull(c.CustomerSize, '') 
                end 
            ,   case e.EFINType 
                    when 'S' then 'Sub' 
                    when 'M' then 'Master'
                    else ''
                end 
            ,   fa.Efiles
            ,   fa.Submitted
            ,   fa.Funded
        ) a join #efin_move b on a.efin = b.efin
    order by
        a.Account
    ,   a.UserID
    ,   a.EFIN

    drop table #efin_move
