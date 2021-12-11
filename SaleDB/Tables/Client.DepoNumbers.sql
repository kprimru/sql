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
        CONSTRAINT [PK_Client.DepoNumbers] PRIMARY KEY CLUSTERED ([DEPO_NUM])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.DepoNumbers(COMPANY_NUMBER)+(DEPO_NUM,STATUS)] ON [Client].[DepoNumbers] ([COMPANY_NUMBER] ASC) INCLUDE ([DEPO_NUM], [STATUS]);
GO
