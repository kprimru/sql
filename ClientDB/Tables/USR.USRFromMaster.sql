USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[USRFromMaster]
(
        [UD_ID]     Int               NOT NULL,
        [UF_DATA]   varbinary             NULL,
        [UF_NAME]   VarChar(100)          NULL,
        CONSTRAINT [PK_USR.USRFromMaster] PRIMARY KEY CLUSTERED ([UD_ID])
);GO
