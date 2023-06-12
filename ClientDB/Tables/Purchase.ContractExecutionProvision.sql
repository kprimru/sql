USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ContractExecutionProvision]
(
        [CEP_ID]      UniqueIdentifier      NOT NULL,
        [CEP_NAME]    VarChar(4000)         NOT NULL,
        [CEP_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.ContractExecutionProvision] PRIMARY KEY CLUSTERED ([CEP_ID])
);
GO
