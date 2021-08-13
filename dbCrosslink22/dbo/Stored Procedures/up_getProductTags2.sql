-- Batch submitted through debugger: C:\tfs\Database\Dev\DBProject\dbCrosslink21\Schema Objects\Schemas\dbo\Programmability\Stored Procedures\up_getProductTags2.proc.sql|2|0|C:\tfs\Database\Dev\DBProject\dbCrosslink21\Schema Objects\Schemas\dbo\Programmability\Stored Procedures\up_getProductTags2.proc.sql
/****** Object:  StoredProcedure [dbo].[up_getProductTags2]    Script Date: 5/8/2019 12:42:30 PM ******/

-- =============================================
-- Author:		Jay Willis
-- Create date: 7/31/2015
-- Description:	create XML Fragment for product tags
-- Update: 10/12/2015 allow removal of products
-- Update: 10/25/2016 only send AD2 if Refundo is selected bank
-- Update: 12/28/2018 send admin records for Online Users
-- Update: 5/8/2019 fix CAF sending for all users
-- Update: 9/9/2020 add RMS tags with doesNotRequireAccountApproval
-- =============================================
CREATE PROCEDURE [dbo].[up_getProductTags2] 
	-- Add the parameters for the stored procedure here
	@userID int
	
	--,
	--@OutString varchar(max) OUTPUT
AS
BEGIN

Declare 
	@XMLString varchar(max) = '',
	@TempString varchar(10) = '',
	@Tag char(3),
	@ProdID int,
	@isEROAddOn bit,
	@EROAddOnAmount money, 
	@isBaseAddon bit,
	@BasePrice money, 
	@BasePriceAddon money,
	@isAutoAdd bit,
	@typeAvailability tinyint,
	@autoAddFinancial bit,
	@autoAddNonFinancial bit,
	@agreeToParticipate bit,
	@XMLCSTString varchar(max) = '',
	@currentSeason int = dbo.getXlinkSeason(),
	@account varchar(8)

SELECT @account = account from dbCrosslinkGlobal..tblUser where user_id = @userID

DECLARE cur_rs CURSOR
FOR
Select tap.tag
,	tap.aprodId
,	tap.eroaddon
,	up.eroaddonfee
,	tap.basePriceAddon
,	tap.basePrice
,	taap.addonAmount
,	tap.autoAdd
,	tap.typeavailability
, up.autoAddFinancial
,	up.autoAddNonFinancial
,	taap.agreeToParticipate
	from tbluser us 
	join tblAccountAncillaryProduct taap on taap.account = us.account
	left join tblXlinkUserProducts up on taap.aprodId = up.aprodId and us.user_id = up.userid
	join tblAncillaryProduct tap on tap.aprodid = taap.aprodId
	left join efin e on e.UserID = us.user_id and e.SelectedBank = 'F'
	where us.user_id = @userID 
	and us.user_id < 996000
	and tap.requireUserApproval = 0
	and tap.doesNotRequireAccountApproval = 0
	and not (tap.tag = 'AD2' and e.SelectedBank <> 'F')
	and	tap.aprodId not in (
		select		uap.aprodId
		from		tblUserAncillaryProduct uap
		where		uap.UserID = @userID)

union -- for requireUserApproval types

Select tap.tag
,	tap.aprodId
,	uap.eroaddon
,	up.eroaddonfee
,	tap.basePriceAddon
,	tap.basePrice
,	uap.addonAmount
,	uap.autoAdd
,	tap.typeavailability
, uap.autoAddFinancial
,	uap.autoAddNonFinancial
,	uap.agreeToParticipate & taap.agreeToParticipate as agreeToParticipate
	from tbluser us 
	join tblAccountAncillaryProduct taap on taap.account = us.account
	left join tblXlinkUserProducts up on taap.aprodId = up.aprodId and us.user_id = up.userid
	join tblAncillaryProduct tap on tap.aprodid = taap.aprodId
	join tblUserAncillaryProduct uap on uap.UserID = us.user_id and uap.ProductTag = tap.tag
	where us.user_id = @userID
	and tap.requireUserApproval = 1
    and tap.doesNotRequireAccountApproval = 0

union -- for doesNotRequireAccountApproval types

Select tap.tag
,	tap.aprodId
,	case when uap.ProductTag is null then tap.eroaddon else uap.eroaddon end eroaddon
,	up.eroaddonfee
,	tap.basePriceAddon
,	tap.basePrice
,	case when uap.ProductTag is null then taap.addonAmount else uap.addonAmount end addonAmount
,	case when uap.ProductTag is null then tap.autoAdd else uap.autoAdd end autoAdd
,	tap.typeavailability
,   case when uap.ProductTag is null then up.autoAddFinancial else uap.autoAddFinancial end autoAddFinancial
,   case when uap.ProductTag is null then up.autoAddNonFinancial else uap.autoAddNonFinancial end autoAddNonFinancial
,   case when uap.ProductTag is null then taap.agreeToParticipate else uap.agreeToParticipate end agreeToParticipate
	from tbluser us 
	join tblAncillaryProduct tap on 1 = 1
	left join tblAccountAncillaryProduct taap on taap.account = us.account and taap.tag = tap.tag
	left join tblUserAncillaryProduct uap on uap.UserID = us.user_id and uap.ProductTag = tap.tag
	left join tblXlinkUserProducts up on up.tag = tap.tag and us.user_id = up.userid
	where us.user_id = @userID
	and tap.requireUserApproval = 0
  and tap.doesNotRequireAccountApproval = 1
	and (taap.aprodId is not null or uap.aprodid is not null)

	OPEN cur_rs;
	FETCH NEXT FROM cur_rs INTO @Tag
	,	@ProdID
	,	@isEROAddOn
	,	@EROAddOnAmount
	,	@isBaseAddon
	,	@BasePrice
	,	@BasePriceAddon
	,	@isAutoAdd
	,	@typeAvailability
	,	@autoAddFinancial
	,	@autoAddNonFinancial
	,	@agreeToParticipate;
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF (@@FETCH_STATUS <> -2)
			BEGIN 
				IF (@isEROAddOn = 1 and ISNULL(@EROAddOnAmount, 0.00) > 0.00 and @agreeToParticipate = 1)
					select @XMLString = @XMLString + '<' + @Tag + 'A>' + convert(varchar(40), replace(floor(IsNull(@EROAddOnAmount,0)*100), '.00','')) + '</' + @Tag + 'A>'
				else 
					select @XMLString = @XMLString + '<' + @Tag + 'A/>'

				if (@isEROAddOn = 1 and ISNULL(@EROAddOnAmount, 0.00) > 0.00 and @agreeToParticipate = 1 and @userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'A' + convert(varchar(40), replace(floor(IsNull(@EROAddOnAmount,0)*100), '.00','')), 'gpt2')
				else if (@userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'A', 'gpt2')

				IF (@isBaseAddon = 1 and @agreeToParticipate = 1)
					select @XMLString = @XMLString + '<' + @Tag + 'B>' + convert(varchar(40), replace(floor((IsNull(@BasePrice,0) + IsNull(@BasePriceAddon,0))*100), '.00',''))  + '</' + @Tag + 'B>'
				else IF (@agreeToParticipate = 1)
					select @XMLString = @XMLString + '<' + @Tag + 'B>' + convert(varchar(40), replace(floor(IsNull(@BasePrice,0)*100), '.00',''))  + '</' + @Tag + 'B>'
				else 
					select @XMLString = @XMLString + '<' + @Tag + 'B/>'

				if (@isBaseAddon = 1 and @agreeToParticipate = 1 and @userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'B' + convert(varchar(40), replace(floor((IsNull(@BasePrice,0) + IsNull(@BasePriceAddon,0))*100), '.00','')), 'gpt2')
				else if (@agreeToParticipate = 1 and @userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'B' + convert(varchar(40), replace(floor(IsNull(@BasePrice,0)*100), '.00','')), 'gpt2')
				else if (@userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'B', 'gpt2')

				IF (@isAutoAdd = 1 and (@typeAvailability = 3 or @typeAvailability = 1) and @autoAddFinancial = 1 and @agreeToParticipate = 1)
					select @XMLString = @XMLString + '<' + @Tag + 'F>X</' + @Tag + 'F>'
				else 
					select @XMLString = @XMLString + '<' + @Tag + 'F/>'

				IF (@isAutoAdd = 1 and (@typeAvailability = 3 or @typeAvailability = 1) and @autoAddFinancial = 1 and @agreeToParticipate = 1 and @userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'FX', 'gpt2')
				else if (@userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'F' , 'gpt2')


				IF (@isAutoAdd = 1 and @typeAvailability = 3 and @autoAddNonFinancial = 1 and @agreeToParticipate = 1)
					select @XMLString = @XMLString + '<' + @Tag + 'N>X</' + @Tag + 'N>'
				else 
					select @XMLString = @XMLString + '<' + @Tag + 'N/>'

				IF (@isAutoAdd = 1 and @typeAvailability = 3 and @autoAddNonFinancial = 1 and @agreeToParticipate = 1 and @userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'NX', 'gpt2')
				else if (@userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'N', 'gpt2')

				select @XMLString = @XMLString + '<' + @Tag + 'L>'
				
				if (@isEROAddOn = 1)
                    select @XMLString = @XMLString + '1'
				else 
                    select @XMLString = @XMLString + '0'

				if (@isEROAddOn = 1 and @userID >= 500000 and @userID < 900000)
                    select @TempString = '1';
				else if (@userID >= 500000 and @userID < 900000)
                    select @TempString = '0'

				if (@isAutoAdd = 1 and @typeAvailability in (1,3))
                    select @XMLString = @XMLString + '1'
				else 
                    select @XMLString = @XMLString + '0'

				if (@isAutoAdd = 1 and @typeAvailability in (1,3) and @userID >= 500000 and @userID < 900000)
                    select @TempString = @TempString + '1'
				else if (@userID >= 500000 and @userID < 900000)
                    select @TempString = @TempString + '0'

				if (@isAutoAdd = 1 and @typeAvailability in (2,3))
                    select @XMLString = @XMLString + '1'
				else 
                    select @XMLString = @XMLString + '0'

				if (@isAutoAdd = 1 and @typeAvailability in (2,3) and @userID >= 500000 and @userID < 900000)
                    select @TempString = @TempString + '1'
				else if (@userID >= 500000 and @userID < 900000)
                    select @TempString = @TempString + '0'
                
				if (@userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'L' + @TempString, 'gpt2')

				if (@userID >= 500000 and @userID < 900000)
					insert into admin (req_type,ssn,param,requestor) values ('T', @userID, @Tag + 'I' + dbo.udf_getAncillaryProdBankApprovalTag(@ProdID), 'gpt2')


				select @XMLString = @XMLString + '</' + @Tag + 'L>' + '<' + @Tag + 'I>' + dbo.udf_getAncillaryProdBankApprovalTag(@ProdID)  + '</' + @Tag + 'I>'
			END;
			FETCH NEXT FROM cur_rs INTO @Tag
			,	@ProdID
			,	@isEROAddOn
			,	@EROAddOnAmount
			,	@isBaseAddon
			,	@BasePrice
			,	@BasePriceAddon
			,	@isAutoAdd
			,	@typeAvailability
			,	@autoAddFinancial
			,	@autoAddNonFinancial
			,	@agreeToParticipate;
			END;
	CLOSE cur_rs;
	DEALLOCATE cur_rs;

	EXEC dbCrosslinkGlobal..up_getCustomTags @account, @userID, @currentSeason, @XMLCSTString OUTPUT

	--set @OutString = @XMLString;
	--print @XMLString;
	select @userID, @XMLCSTString + @XMLString
	END


