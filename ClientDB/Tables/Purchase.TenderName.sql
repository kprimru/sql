USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderName]
(
        [TN_ID]      UniqueIdentifier      NOT NULL,
        [TN_NAME]    VarChar(500)          NOT NULL,
        [TN_SHORT]   VarChar(100)          NOT NULL,
        CONSTRAINT [PK_Purchase.TenderName] PRIMARY KEY CLUSTERED ([TN_ID])
);GO
