USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[Trademark]
(
        [TM_ID]      UniqueIdentifier      NOT NULL,
        [TM_NAME]    VarChar(4000)         NOT NULL,
        [TM_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.Trademark] PRIMARY KEY CLUSTERED ([TM_ID])
);GO
