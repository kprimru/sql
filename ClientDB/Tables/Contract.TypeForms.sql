USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[TypeForms]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [ID_TYPE]   UniqueIdentifier      NOT NULL,
        [ID_FORM]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Contract.TypeForms] PRIMARY KEY CLUSTERED ([ID])
);
GO
