CREATE TABLE [dbo].[reftblMobileCalcStatus] (
    [mobile_calc_status] INT           IDENTITY (1, 1) NOT NULL,
    [short_desc]         VARCHAR (50)  NULL,
    [long_desc]          VARCHAR (200) NULL,
    [created_dttm]       DATETIME2 (7) NULL,
    [updated_dttm]       DATETIME2 (7) NULL,
    CONSTRAINT [PK_mobile_calc_status] PRIMARY KEY CLUSTERED ([mobile_calc_status] ASC)
);

