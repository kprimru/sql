USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RivalStatus]
(
        [RS_ID]     Int           Identity(1,1)   NOT NULL,
        [RS_NAME]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.RivalStatus] PRIMARY KEY CLUSTERED ([RS_ID])
);GO
