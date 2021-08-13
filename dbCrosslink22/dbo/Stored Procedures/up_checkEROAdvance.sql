CREATE procedure [dbo].[up_checkEROAdvance] --799876 --578488
    @efin int
as

    set nocount on 

select 
        lsa.BankID
    from
        dbo.vwlatestsubmittedapplication lsa join (
            select
                rr3.efin
            ,   rr3.transmitterTrackingId BankAppID
                ,  'R' BankID
            from
                dbBanking21.dbo.tblRepublicRecord3 rr3
            where
                rr3.rapcollectionind = 'Y'
                and rr3.efin = @efin
            union select
                srd.efin
            ,   srd.transmitterUse BankAppID
            ,   'S' BankID
            from
                dbBanking21.dbo.tblSBTPGRecordD srd
            where
                srd.eroAdvanceOutstanding = 'X'
                and srd.efin = @efin
            union select 
                rr3.efin
            ,   rr3.transmitterTrackingId BankAppID
            ,   'F' BankID
            from
                dbBanking21.dbo.tblRefundoRecord3 rr3
            where
                left(rr3.transmitterEroId, 1) = '1'
                and rr3.efin = @efin
            union select 
                ra3.officeEFIN
            ,   ra3.officeNumber BankAppID
            ,   'V' BankID
            from 
                dbBanking21.dbo.tblRefundAdvantageRecordR ra3
            where
                ra3.preseasonLoanStatus = 'ACCEPTED'
                and ra3.officeEFIN = @efin
        ) a on lsa.Efin = a.efin
            and lsa.BankID = a.BankID
            and lsa.BankAppID = a.BankAppID
            and lsa.Registered <> 'P'

--exec up_checkEROAdvance 400394