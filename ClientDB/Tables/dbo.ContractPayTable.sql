USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPayTable]
(
        [ContractPayID]      Int            Identity(1,1)   NOT NULL,
        [ContractPayName]    VarChar(250)                   NOT NULL,
        [ContractPayDay]     SmallInt                           NULL,
        [ContractPayMonth]   SmallInt                           NULL,
        CONSTRAINT [PK_dbo.ContractPayTable] PRIMARY KEY CLUSTERED ([ContractPayID])
);GO
