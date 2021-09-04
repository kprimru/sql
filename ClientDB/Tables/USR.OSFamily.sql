USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[OSFamily]
(
        [OF_ID]     Int            Identity(1,1)   NOT NULL,
        [OF_NAME]   VarChar(100)                   NOT NULL,
        CONSTRAINT [PK_USR.OSFamily] PRIMARY KEY CLUSTERED ([OF_ID])
);GO
