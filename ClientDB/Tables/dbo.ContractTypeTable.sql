USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTypeTable]
(
        [ContractTypeID]     Int           Identity(1,1)   NOT NULL,
        [ContractTypeName]   VarChar(50)                   NOT NULL,
        [ContractTypeRate]   Bit                           NOT NULL,
        [ContractTypeHst]    Bit                               NULL,
        CONSTRAINT [PK_dbo.ContractTypeTable] PRIMARY KEY CLUSTERED ([ContractTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ContractTypeTable(ContractTypeName)] ON [dbo].[ContractTypeTable] ([ContractTypeName] ASC);
GO
