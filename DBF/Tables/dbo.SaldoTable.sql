USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SaldoTable]
(
        [SL_ID]              bigint          Identity(1,1)   NOT NULL,
        [SL_DATE]            SmallDateTime                   NOT NULL,
        [SL_ID_CLIENT]       Int                             NOT NULL,
        [SL_ID_DISTR]        Int                             NOT NULL,
        [SL_ID_BILL_DIS]     Int                                 NULL,
        [SL_ID_IN_DIS]       Int                                 NULL,
        [SL_ID_ACT_DIS]      Int                                 NULL,
        [SL_ID_CONSIG_DIS]   Int                                 NULL,
        [SL_REST]            Money                           NOT NULL,
        [SL_TP]              TinyInt                             NULL,
        [SL_BEZ_NDS]         Money                               NULL,
        CONSTRAINT [PK_dbo.SaldoTable] PRIMARY KEY NONCLUSTERED ([SL_ID]),
        CONSTRAINT [FK_dbo.SaldoTable(SL_ID_BILL_DIS)_dbo.BillDistrTable(BD_ID)] FOREIGN KEY  ([SL_ID_BILL_DIS]) REFERENCES [dbo].[BillDistrTable] ([BD_ID]),
        CONSTRAINT [FK_dbo.SaldoTable(SL_ID_IN_DIS)_dbo.IncomeDistrTable(ID_ID)] FOREIGN KEY  ([SL_ID_IN_DIS]) REFERENCES [dbo].[IncomeDistrTable] ([ID_ID]),
        CONSTRAINT [FK_dbo.SaldoTable(SL_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([SL_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.SaldoTable(SL_ID_ACT_DIS)_dbo.ActDistrTable(AD_ID)] FOREIGN KEY  ([SL_ID_ACT_DIS]) REFERENCES [dbo].[ActDistrTable] ([AD_ID]),
        CONSTRAINT [FK_dbo.SaldoTable(SL_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([SL_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID]),
        CONSTRAINT [FK_dbo.SaldoTable(SL_ID_CONSIG_DIS)_dbo.ConsignmentDetailTable(CSD_ID)] FOREIGN KEY  ([SL_ID_CONSIG_DIS]) REFERENCES [dbo].[ConsignmentDetailTable] ([CSD_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.SaldoTable(SL_ID_CLIENT,SL_ID_DISTR,SL_DATE)] ON [dbo].[SaldoTable] ([SL_ID_CLIENT] ASC, [SL_ID_DISTR] ASC, [SL_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.SaldoTable(SL_ID_ACT_DIS)+(SL_ID,SL_ID_CLIENT,SL_ID_DISTR,SL_REST)] ON [dbo].[SaldoTable] ([SL_ID_ACT_DIS] ASC) INCLUDE ([SL_ID], [SL_ID_CLIENT], [SL_ID_DISTR], [SL_REST]);
CREATE NONCLUSTERED INDEX [IX_dbo.SaldoTable(SL_ID_BILL_DIS)+(SL_ID,SL_ID_CLIENT,SL_ID_DISTR,SL_REST)] ON [dbo].[SaldoTable] ([SL_ID_BILL_DIS] ASC) INCLUDE ([SL_ID], [SL_ID_CLIENT], [SL_ID_DISTR], [SL_REST]);
CREATE NONCLUSTERED INDEX [IX_dbo.SaldoTable(SL_ID_DISTR,SL_DATE)+(SL_ID,SL_ID_CLIENT,SL_REST,SL_TP)] ON [dbo].[SaldoTable] ([SL_ID_DISTR] ASC, [SL_DATE] ASC) INCLUDE ([SL_ID], [SL_ID_CLIENT], [SL_REST], [SL_TP]);
CREATE NONCLUSTERED INDEX [IX_dbo.SaldoTable(SL_ID_IN_DIS)+(SL_ID,SL_ID_CLIENT,SL_ID_DISTR,SL_REST)] ON [dbo].[SaldoTable] ([SL_ID_IN_DIS] ASC) INCLUDE ([SL_ID], [SL_ID_CLIENT], [SL_ID_DISTR], [SL_REST]);
GO
