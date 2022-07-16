USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Notify].[Message]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_SENDER]      UniqueIdentifier      NOT NULL,
        [ID_RECEIVER]    UniqueIdentifier      NOT NULL,
        [MODULE]         NVarChar(256)             NULL,
        [TXT]            NVarChar(Max)         NOT NULL,
        [ID_EVENT]       UniqueIdentifier          NULL,
        [DATE]           DateTime              NOT NULL,
        [RECEIVE_DATE]   DateTime                  NULL,
        CONSTRAINT [PK_Notify.Message] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Notify.Message(RECEIVE_DATE)] ON [Notify].[Message] ([RECEIVE_DATE] ASC);
GO
