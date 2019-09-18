CREATE TABLE [dbo].[ProactisRequestType] (
    [Id]   INT           IDENTITY (1, 1) NOT NULL,
    [NAME] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ProactisRequestTypeId] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [AK_ProactisRequestType_Name] UNIQUE NONCLUSTERED ([NAME] ASC)
);

