USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileType]
(
        [FT_ID]     TinyInt         Identity(1,1)   NOT NULL,
        [FT_NAME]   NVarChar(128)                   NOT NULL,
        CONSTRAINT [PK_dbo.FileType] PRIMARY KEY CLUSTERED ([FT_ID])
);
GO
