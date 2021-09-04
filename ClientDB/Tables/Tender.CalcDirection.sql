USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[CalcDirection]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Tender.CalcDirection] PRIMARY KEY CLUSTERED ([ID])
);GO
