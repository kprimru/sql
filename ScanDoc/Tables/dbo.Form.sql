USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Form]
(
        [ID]     Int             Identity(1,1)   NOT NULL,
        [NAME]   NVarChar(256)                   NOT NULL,
        [LAST]   DateTime                        NOT NULL,
        CONSTRAINT [PK_Form] PRIMARY KEY CLUSTERED ([ID])
);
GO
