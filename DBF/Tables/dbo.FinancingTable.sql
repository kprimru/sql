USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancingTable]
(
        [FIN_ID]         SmallInt      Identity(1,1)   NOT NULL,
        [FIN_NAME]       VarChar(50)                   NOT NULL,
        [FIN_ACTIVE]     Bit                           NOT NULL,
        [FIN_OLD_CODE]   Int                               NULL,
        CONSTRAINT [PK_dbo.FinancingTable] PRIMARY KEY CLUSTERED ([FIN_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.FinancingTable()] ON [dbo].[FinancingTable] ([FIN_NAME] ASC);
GO
