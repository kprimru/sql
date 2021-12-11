USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DisconnectReason]
(
        [DR_ID]     UniqueIdentifier      NOT NULL,
        [DR_NAME]   VarChar(100)          NOT NULL,
        CONSTRAINT [PK_dbo.DisconnectReason] PRIMARY KEY CLUSTERED ([DR_ID])
);
GO
