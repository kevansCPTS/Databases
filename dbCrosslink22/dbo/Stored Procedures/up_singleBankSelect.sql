


CREATE procedure [dbo].[up_singleBankSelect]
as

declare @efin       int
declare @bankId     char(1)
declare @account    varchar(8)


create table #eList(
    efin        int
,   bankId      char(1)
,   account     varchar(8)
)

    set nocount on

    insert #eList
        select
            lsba.Efin
        ,   lsba.BankID
        ,   lsba.AccountID
        from
            (
                select
                    lsba1.Efin
                ,   lsba1.BankID
                ,   lsba1.AccountID
                ,   count(*) over (partition by lsba1.Efin) AS AppCount

                from
                    dbo.vwLatestBankApplication lsba1
                where
                    lsba1.Deleted != 1
                      and lsba1.Registered = 'A'
                      and isnull(lsba1.SystemHold, 0) != 1 
                      and lsba1.SelectedBank is null
            ) lsba
        where
            lsba.AppCount = 1


    delete 
        e
    from 
        #eList e join (
                        select
                            lba2.Efin
                        from 
                            dbo.vwLatestBankApplication lba2
                        where
                            lba2.Registered = 'P'
                            and lba2.Deleted != 1    
                      ) pEfin on e.Efin = pEfin.Efin


    declare curBankSel cursor fast_forward for
        select 
            e.Efin
        ,   e.BankID
        ,   e.Account
        from 
            #eList e left join (
                                    select
                                        lsa2.efin
                                    ,   lsa2.SelectedBank
                                    from
                                        (
                                            select 
                                                a.efin
                                            ,   lsa1.SelectedBank
                                            ,	count(*) over ( partition by a.efin) AS 'AppCount' 
                                            from
                                                dbo.vwlatestsubmittedapplication lsa1 join (
                                                                                                select
                                                                                                    rr3.efin efin
                                                                                                ,   rr3.transmitterTrackingId BankAppID
                                                                                                    ,  'R' BankID
                                                                                                from
                                                                                                    dbBanking21.dbo.tblRepublicRecord3 rr3
                                                                                                where
                                                                                                    rr3.rapcollectionind = 'Y'
                                                                                                union select
                                                                                                    rr3.efin efin
                                                                                                ,   rr3.transmitterUse BankAppID
                                                                                                ,   'S' BankID
                                                                                                from
                                                                                                    dbBanking21.dbo.tblSBTPGRecordD rr3
                                                                                                where
                                                                                                    rr3.eroAdvanceOutstanding = 'X'
                                                                                                union select 
                                                                                                    rr3.efin efin
                                                                                                ,   rr3.transmitterTrackingId BankAppID
                                                                                                ,   'F' BankID
                                                                                                from
                                                                                                    dbBanking21.dbo.tblRefundoRecord3 rr3
                                                                                                where
                                                                                                    left(rr3.transmitterEroId, 1) = '1'
                                                                                                union select 
                                                                                                    rr3.officeEFIN efin
                                                                                                ,   rr3.officeNumber BankAppID
                                                                                                ,   'V' BankID
                                                                                                from 
                                                                                                    dbBanking21.dbo.tblRefundAdvantageRecordR rr3
                                                                                                where
                                                                                                    rr3.preseasonLoanStatus = 'ACCEPTED'
                                                                                            ) a on lsa1.Efin = a.efin
                                                    and lsa1.BankID = a.BankID
                                                    and lsa1.BankAppID = a.BankAppID
                                                    and lsa1.Registered <> 'P'
		                                            and lsa1.SelectedBank is null
                                        ) lsa2
                                    where
                                        lsa2.AppCount = 1    
                                  ) lsa on e.Efin = lsa.efin
        where
            (
                lsa.efin is null            
                    or ( lsa.efin is not null 
                            and e.BankID = isnull(lsa.SelectedBank, e.BankID))
            )

    open curBankSel
    fetch next from curBankSel into @efin, @bankId, @account

    while @@fetch_status = 0
        begin
            exec dbo.up_submitBankSelect @efin, @bankId, @account 
            print 'Account: ' + @account + '  EFIN: ' + convert(varchar(6),@efin) + '  BankId: ' + @bankId
            fetch next from curBankSel into @efin, @bankId, @account
        end 

    close curBankSel
    deallocate curBankSel

    drop table #eList


