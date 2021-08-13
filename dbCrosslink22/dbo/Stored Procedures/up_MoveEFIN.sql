
Create procedure [dbo].[up_MoveEFIN]
@efin int
,@olduser int
,@newuser int
as
BEGIN
--declare @efin int = 100
--declare @olduser int = 52
--declare @newuser int = 23221
declare @account varchar(8)
declare @efinid int

select @efinid = efinid from efin where efin = @efin
select @account = account from dbCrosslinkGlobal..tblUser where user_id = @newuser

update efin set UserID = @newuser, Account = @account where UserID = @olduser and EfinID = @efinid
update SBTPG_BankApp set UserID = @newuser where UserID = @olduser and EfinID = @efinid
update SBTPGW_BankApp set UserID = @newuser where UserID = @olduser and EfinID = @efinid
update Refundo_BankApp set UserID = @newuser where UserID = @olduser and EfinID = @efinid
update Refund_Advantage_BankApp set UserID = @newuser where UserID = @olduser and EfinID = @efinid
update Republic_BankApp set UserID = @newuser where UserID = @olduser and EfinID = @efinid
END

