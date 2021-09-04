USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTypeTable]
(
        [CTT_ID]         SmallInt      Identity(1,1)   NOT NULL,
        [CTT_NAME]       VarChar(50)                   NOT NULL,
        [CTT_ACTIVE]     Bit                           NOT NULL,
        [CTT_OLD_CODE]   Int                               NULL,
        CONSTRAINT [PK_dbo.ContractTypeTable] PRIMARY KEY CLUSTERED ([CTT_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ContractTypeTable()] ON [dbo].[ContractTypeTable] ([CTT_NAME] ASC);
GO
