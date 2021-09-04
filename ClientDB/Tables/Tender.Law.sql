USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Law]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Tender.Law] PRIMARY KEY CLUSTERED ([ID])
);GO
