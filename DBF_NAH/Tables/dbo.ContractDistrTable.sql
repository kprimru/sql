USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractDistrTable]
(
        [COD_ID]            Int   Identity(1,1)   NOT NULL,
        [COD_ID_CONTRACT]   Int                   NOT NULL,
        [COD_ID_DISTR]      Int                   NOT NULL,
        CONSTRAINT [PK_dbo.ContractDistrTable] PRIMARY KEY NONCLUSTERED ([COD_ID]),
        CONSTRAINT [FK_dbo.ContractDistrTable(COD_ID_CONTRACT)_dbo.ContractTable(CO_ID)] FOREIGN KEY  ([COD_ID_CONTRACT]) REFERENCES [dbo].[ContractTable] ([CO_ID]),
        CONSTRAINT [FK_dbo.ContractDistrTable(COD_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([COD_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ContractDistrTable(COD_ID_CONTRACT,COD_ID_DISTR)] ON [dbo].[ContractDistrTable] ([COD_ID_CONTRACT] ASC, [COD_ID_DISTR] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ContractDistrTable()] ON [dbo].[ContractDistrTable] ([COD_ID_DISTR] ASC, [COD_ID_CONTRACT] ASC);
GO
