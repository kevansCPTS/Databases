CREATE procedure [dbo].[up_processCADRMemberData]
as

set nocount on


    -- Get new signups
    insert [dbo].[tblCADMemberData](
    [pssn]
    ,   [Account]
    ,   [EFIN]
    ,   [UserId]
    ,   [fdate]
    ,   [req_cadr_fee]
    ,   [cadr_pay_date]
    ,   [cadr_pay_amt]
    ,   [StatusId]
    ,   [StatusDate]
    )
        select
            tm.pssn
        ,   u.account 
        ,   tm.efin
        ,   tm.[user_id]
        ,   tm.fdate
        ,   cad.reqAmount req_cadr_fee
        ,   cad.payDate cadr_pay_date
        ,   cad.payAmount cadr_pay_amt
        ,   1
        ,   getdate()
        from    
            [dbo].[tblTaxmast] tm join [dbCrosslinkGlobal].[dbo].[tblUser] u on tm.[user_id] = u.[user_id]
                and tm.irs_acc_cd = 'A'
                and tm.ral_flag = 5
            join [dbo].[tblLoanApp] la on tm.pssn = la.pssn
                and isdate(la.pri_dob) = 1
            join (
                    select
                        tf.pssn
                    ,   sum(tf.reqAmount) reqAmount
                    ,   max(tf.payDate) payDate
                    ,   sum(tf.payAmount) payAmount
                    from
                        dbo.tblTaxmastFee tf
                    where
                        tf.tag = 'CAD'
                    group by
                        tf.pssn   
                 ) cad on tm.pssn = cad.pssn
            left join [dbo].[tblCADMemberData] cmd on tm.pssn = cmd.pssn
        where
            cmd.pssn is null


    -- Get existing members that are newly fully funded.
    update cmd
        set cmd.fdate = tm.fdate
    ,   cmd.req_cadr_fee = cad.req_cadr_fee
    ,   cmd.cadr_pay_date = cad.cadr_pay_date
    ,   cmd.cadr_pay_amt = cad.cadr_pay_amt
    ,   cmd.StatusId = 3
    ,   cmd.StatusDate = getdate()
    from    
        [dbo].[tblCADMemberData] cmd join [dbo].[tblTaxmast] tm on cmd.pssn = tm.pssn
            and cmd.StatusId = 1
        join (
                    select
                        tf.pssn
                    ,   sum(tf.reqAmount) req_cadr_fee
                    ,   max(tf.payDate) cadr_pay_date
                    ,   sum(tf.payAmount) cadr_pay_amt
                    from
                        dbo.tblTaxmastFee tf
                    where
                        tf.tag = 'CAD'
                    group by
                        tf.pssn 
                    having
                        sum(tf.payAmount) >= sum(tf.reqAmount) 
        ) cad on cmd.pssn = cad.pssn







