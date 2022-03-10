USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Messages]
(
        [MSG_ID]       UniqueIdentifier      NOT NULL,
        [MSG_DATE]     DateTime              NOT NULL,
        [MSG_USER]     VarChar(128)          NOT NULL,
        [MSG_TEXT]     VarChar(Max)          NOT NULL,
        [MSG_NOTIFY]   TinyInt               NOT NULL,
        [MSG_DATA]     VarChar(50)           NOT NULL,
        [MSG_ROW]      UniqueIdentifier          NULL,
        [MSG_SEND]     TinyInt                   NULL,
        CONSTRAINT [PK_Common.Messages] PRIMARY KEY CLUSTERED ([MSG_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.Messages(MSG_NOTIFY)+(MSG_ID,MSG_USER)] ON [Common].[Messages] ([MSG_NOTIFY] ASC) INCLUDE ([MSG_ID], [MSG_USER]);
CREATE NONCLUSTERED INDEX [IX_Common.Messages(MSG_ROW)+(MSG_USER,MSG_TEXT,MSG_NOTIFY)] ON [Common].[Messages] ([MSG_ROW] ASC) INCLUDE ([MSG_USER], [MSG_TEXT], [MSG_NOTIFY]);
GO
