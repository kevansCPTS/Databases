create procedure up_accountHasFilledReturns  --'RIVEDG'
    @account    varchar(8)
as

set nocount on  

select 
    case when  count(*) > 0 then 1 else 0 end hasReturn
from    
    tblTaxmast tm 
where
    tm.[user_id] in(
                    select 
                        u.[user_id]
                    from 
                        dbCrosslinkGlobal.dbo.tblUser u
                    where
                        u.account = @account)