USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Company]
(
        [ID]     Int             Identity(1,1)   NOT NULL,
        [NAME]   NVarChar(256)                   NOT NULL,
        [LAST]   DateTime                        NOT NULL,
        CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED ([ID])
);
GO
