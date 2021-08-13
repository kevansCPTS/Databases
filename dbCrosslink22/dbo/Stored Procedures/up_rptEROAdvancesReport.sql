
-- =============================================
-- Author:		Sundeep Brar
-- Create date: 05/19/2020
-- Description:	Stored procedure for inteneral report > customer support report > EROAdvancesReport
-- =============================================
CREATE PROCEDURE [dbo].[up_rptEROAdvancesReport] --'R'
	@BankID varchar(10)
AS
BEGIN

declare @sqlstr             nvarchar(max)
declare @sSeason4           char(4)
declare @sSeason2           char(2)


    set nocount on
    
    set @sSeason2 = right(db_name(),2)
    set @sSeason4 = '20' + @sSeason2

    set @sqlstr = '
        declare @output table (
            AccountID               varchar(8)
        ,   UserID                  int
        ,   Efin                    int
        ,   Bank                    varchar(256)
        ,   eroAdvanceOutstanding   char(1)
        ,   parentAccount           varchar(8)
        )

        if not exists (select t.[name] from dbBanking' + @sSeason2 + '.sys.tables t where t.[name] = ''tblRefundAdvantageRecordR'')
            or not exists (select t.[name] from dbBanking' + @sSeason2 + '.sys.tables t where t.[name] = ''tblRepublicRecord3'')
            or not exists (select t.[name] from dbBanking' + @sSeason2 + '.sys.tables t where t.[name] = ''tblSBTPGRecordD'')
            or not exists (select t.[name] from dbBanking' + @sSeason2 + '.sys.tables t where t.[name] = ''tblRefundoRecord3'')

            begin
                select * from @output
                return
            end         

        select distinct
            lsa.AccountID
        ,   lsa.UserID
        ,   lsa.Efin
        ,   case 
                when lsa.BankID = ''F'' then ''Refundo''
		        when lsa.BankID = ''V'' then ''Refund Advantage''
		        when lsa.BankID = ''R'' then ''Republic''
		        when lsa.BankID = ''S'' then ''TPG''
                else ''''
	          end Bank
        ,   eroAdvanceOutstanding
        ,   ch.parentAccount
        from
            dbo.vwlatestsubmittedapplication lsa join (
				                                        select
					                                        rr3.efin
				                                        ,   rr3.transmitterTrackingId BankAppID
				                                        ,  ''R'' BankID
				                                        , case when rapCollectionInd = ''Y'' then ''X'' else '''' end eroAdvanceOutstanding
		                                                from
					                                        dbBanking' + @sSeason2 + '.dbo.tblRepublicRecord3 rr3
				                                        union select
					                                        srd.efin
				                                        ,   srd.transmitterUse BankAppID
				                                        ,   ''S'' BankID
		                                                ,   eroAdvanceOutstanding 
				                                        from
					                                        dbBanking' + @sSeason2 + '.dbo.tblSBTPGRecordD srd
				                                        union select 
					                                        rr3.efin
				                                        ,   rr3.transmitterTrackingId BankAppID
				                                        ,   ''F'' BankID
		                                                ,   case when spaProductEroAdvance = ''1'' then ''X'' else '''' end eroAdvanceOutstanding
				                                        from
					                                        dbBanking' + @sSeason2 + '.dbo.tblRefundoRecord3 rr3
				                                        union select 
					                                        ra3.officeEFIN
				                                        ,   ra3.officeNumber BankAppID
				                                        ,   ''V'' BankID
		                                                ,   case when preseasonLoanStatus = ''ACCEPTED'' then ''X'' else '''' end eroAdvanceOutstanding
				                                        from 
					                                        dbBanking' + @sSeason2 + '.dbo.tblRefundAdvantageRecordR ra3
			                                         ) a on lsa.Efin = a.efin
                and lsa.BankID = a.BankID
                and lsa.BankAppID = a.BankAppID
                and lsa.Registered <> ''P''
        left join dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch on lsa.AccountId = ch.childAccount
            and ch.season = ' + @sSeason4 + '
        where 
            eroAdvanceOutstanding = ''X''' 
            + case when @BankID is not null then ' and lsa.BankID = ''' + @BankID + '''' else '' end + '
        order by
            lsa.AccountID
        ,	lsa.UserID
        ,	lsa.Efin'

    exec sp_executeSql @sqlstr


END

