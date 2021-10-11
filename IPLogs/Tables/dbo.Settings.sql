USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Settings]
(
        [ST_ID]      Int              Identity(1,1)   NOT NULL,
        [ST_NAME]    NVarChar(128)                    NOT NULL,
        [ST_NOTE]    NVarChar(1024)                   NOT NULL,
        [ST_VALUE]   NVarChar(1024)                   NOT NULL,
        CONSTRAINT [PK_dbo.Settings] PRIMARY KEY CLUSTERED ([ST_ID])
);GO
