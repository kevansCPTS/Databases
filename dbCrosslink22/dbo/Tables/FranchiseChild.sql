CREATE TABLE [dbo].[FranchiseChild] (
    [ParentUserID] INT NOT NULL,
    [ChildUserID]  INT NOT NULL,
    CONSTRAINT [PK_FranchiseChild_1] PRIMARY KEY CLUSTERED ([ChildUserID] ASC),
    CONSTRAINT [FK_FranchiseChild_FranchiseOwner] FOREIGN KEY ([ParentUserID]) REFERENCES [dbo].[FranchiseOwner] ([UserID])
);

