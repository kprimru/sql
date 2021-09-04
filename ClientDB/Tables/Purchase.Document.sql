USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[Document]
(
        [DC_ID]      UniqueIdentifier      NOT NULL,
        [DC_NAME]    VarChar(4000)         NOT NULL,
        [DC_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.Document] PRIMARY KEY CLUSTERED ([DC_ID])
);GO
