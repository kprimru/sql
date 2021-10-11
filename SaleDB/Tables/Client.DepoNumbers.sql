USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[DepoNumbers]
(
        [DEPO_NUM]         Int                NOT NULL,
        [COMPANY_NAME]     NVarChar(896)          NULL,
        [STATUS]           Int                NOT NULL,
        [COMPANY_NUMBER]   Int                    NULL,
        CONSTRAINT [PK_DepoNumbers] PRIMARY KEY CLUSTERED ([DEPO_NUM])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DepoNumbers] ON [Client].[DepoNumbers] ([DEPO_NUM] ASC);
GO
