USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Status]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [PSEDO]   NVarChar(128)         NOT NULL,
        [ORD]     Int                   NOT NULL,
        CONSTRAINT [PK_Tender.Status] PRIMARY KEY CLUSTERED ([ID])
);
GO
