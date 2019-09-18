CREATE TABLE [dbo].[ProactisRequests] (
    [Id]                     INT                IDENTITY (1, 1) NOT NULL,
    [ProactisDocumentNumber] NVARCHAR (MAX)     NULL,
    [DocumentXml]            NVARCHAR (MAX)     NULL,
    [ImageString]            NVARCHAR (MAX)     NULL,
    [CreatedOn]              DATETIMEOFFSET (7) DEFAULT (sysdatetimeoffset()) NULL,
    [CreatedBy]              NVARCHAR (100)     NULL,
    [CreatedByProcess]       NVARCHAR (200)     NULL,
    [IsSuccessful]           BIT                DEFAULT ((1)) NULL,
    [RequestTypeId]          INT                NOT NULL,
    [IsProcessed]            BIT                CONSTRAINT [DF_IsProcessed] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ProactisRequestsId] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ProactisRequests_RequestType] FOREIGN KEY ([RequestTypeId]) REFERENCES [dbo].[ProactisRequestType] ([Id])
);

