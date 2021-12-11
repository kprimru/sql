USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DebtType]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(512)         NOT NULL,
        [SHORT]   NVarChar(64)          NOT NULL,
        CONSTRAINT [PK_dbo.DebtType] PRIMARY KEY CLUSTERED ([ID])
);
GO
