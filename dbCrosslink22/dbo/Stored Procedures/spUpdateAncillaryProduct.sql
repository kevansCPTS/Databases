-- =============================================
-- Author:		Sundeep Brar
-- Create date: 06/12/2019
-- =============================================
CREATE PROCEDURE spUpdateAncillaryProduct

	@AprodId int,
	@groupId int,	
	@tag char(3),	
	@name varchar(255),	
	@company varchar(255),
	@basePrice money ,
	@basePriceAddon	bit,
	@eroAddon bit,
	@desktop bit,
	@mso bit,
	@typeAvailability tinyint,
	@autoAdd bit,
	@comment varchar(255),	
	@createBy varchar(50),	
	@modifyBy varchar(50),
	@showAgreement	bit	,
	@agreementImage varchar(max),
	@agreementFileType	varchar(3),
	@agreementHeader varchar(100),	
	@agreementDescription varchar(4000),
	@baseEROAddOn money,
	@requireUserApproval bit
	
AS
	BEGIN
		UPDATE 
			tblAncillaryProduct 
		SET 
			groupID = @groupId,
			tag = @tag, 
			name = @name, 
			company = @company, 
			basePrice = @basePrice, 
			basePriceAddon = @basePriceAddon, 
			eroAddon = @eroAddon, 
			desktop = @desktop, 
			mso = @mso, 
			typeAvailability = @typeAvailability, 
			autoAdd = @autoAdd, 
			comment = @comment, 
			modifyDate = getDate(), 
			modifyBy = @modifyBy, 
			showAgreement = @showAgreement, 
			agreementImage = convert(varBinary(max),@agreementImage), 
			agreementFileType = @agreementFileType, 
			agreementHeader = @agreementHeader,
			agreementDescription = @agreementDescription,
			baseEROAddOn = @baseEROAddOn,
			requireUserApproval = @requireUserApproval
		WHERE 
			aprodid = @AprodId
	END
