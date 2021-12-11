USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[SpecificationForms]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [ID_SPECIFICATION]   UniqueIdentifier      NOT NULL,
        [ID_FORM]            UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Contract.SpecificationForms] PRIMARY KEY CLUSTERED ([ID])
);
GO
