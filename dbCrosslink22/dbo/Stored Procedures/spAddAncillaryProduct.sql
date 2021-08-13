-- =============================================
-- Author:		Sundeep Brar
-- Create date: 06/12/2019
-- =============================================
CREATE PROCEDURE spAddAncillaryProduct

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
		INSERT INTO tblAncillaryProduct 
		(
			groupId,
			tag,
			name,
			company,
			basePrice,
			basePriceAddon,
			eroAddon,
			desktop, 
			mso,
			typeAvailability,
			autoAdd,
			comment,
			createDate,
			createBy,
			modifyDate,
			modifyBy, 
			showAgreement,
			agreementImage,
			agreementFileType,
			agreementHeader,
			agreementDescription,
			baseEROAddOn,
			requireUserApproval 
		) 
		VALUES 
		(
			@groupId, 
			@tag, 
			@name, 
			@company, 
			@basePrice, 
			@basePriceAddon, 
			@eroAddon, 
			@desktop, 
			@mso, 
			@typeAvailability, 
			@autoAdd, 
			@comment,  
			getDate(), 
			@createBy, 
			getDate(), 
			@modifyBy, 
			@showAgreement, 
			convert(varBinary(max),@agreementImage), 
			@agreementFileType, 
			@agreementHeader, 
			@agreementDescription, 
			@baseEROAddOn,
			@requireUserApproval
		)
	END
