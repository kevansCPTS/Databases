CREATE TABLE [dbo].[ReturnStatusLookup] (
    [StatusCodeAscii]   INT          NOT NULL,
    [StatusDescription] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ReturnStatusLookup] PRIMARY KEY CLUSTERED ([StatusCodeAscii] ASC)
);

