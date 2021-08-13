CREATE TABLE [dbo].[tblXlinkUserProducts] (
    [userID]              INT          NOT NULL,
    [account]             VARCHAR (8)  NOT NULL,
    [aprodId]             INT          NOT NULL,
    [tag]                 CHAR (3)     NOT NULL,
    [eroAddonFee]         MONEY        CONSTRAINT [DF_tblXlinkUserSettings_addOnFee] DEFAULT ((0)) NULL,
    [autoAddFinancial]    BIT          CONSTRAINT [DF_tblXlinkUserSettings_autoAddFinancial] DEFAULT ((0)) NOT NULL,
    [autoAddNonFinancial] BIT          CONSTRAINT [DF_tblXlinkUserSettings_autoAddNonFinancial] DEFAULT ((0)) NOT NULL,
    [createDate]          DATETIME     CONSTRAINT [DF_tblXlinkUserSettings_createDate] DEFAULT (getdate()) NULL,
    [createBy]            VARCHAR (50) CONSTRAINT [DF_tblXlinkUserSettings_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate]          DATETIME     CONSTRAINT [DF_tblXlinkUserSettings_modifyDate] DEFAULT (getdate()) NULL,
    [modifyBy]            VARCHAR (50) CONSTRAINT [DF_tblXlinkUserSettings__modifyBy] DEFAULT (original_login()) NOT NULL,
    CONSTRAINT [PK_tblXlinkUserProducts_1] PRIMARY KEY CLUSTERED ([userID] ASC, [aprodId] ASC),
    CONSTRAINT [FK_tblXlinkUserProducts_tblAncillaryProduct] FOREIGN KEY ([aprodId]) REFERENCES [dbo].[tblAncillaryProduct] ([aprodId])
);


GO

-- =============================================
-- Author:		Jay Willis
-- Create date: 9/17/2020
-- Description:	
-- Update: 
-- =============================================
CREATE TRIGGER [dbo].[tgrtblXlinkUserProducts] 
   ON  [dbo].[tblXlinkUserProducts] 
   AFTER INSERT,UPDATE
AS 
BEGIN

	declare @userid int

	DECLARE cur_rs2 CURSOR
	FOR
    select
        u.[user_id]
    from
        inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.userID = u.user_id
            and u.[user_id] < 996000
		--where i.agreeToParticipate = 1

	OPEN cur_rs2;
	FETCH NEXT FROM cur_rs2 INTO @userid
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
				BEGIN 
			exec spPublishTags @userid
		END;
		FETCH NEXT FROM cur_rs2 INTO @userid
		END;
	CLOSE cur_rs2;
	DEALLOCATE cur_rs2;



END


