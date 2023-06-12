USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceFactDetailTable]
(
        [IFD_ID]           bigint         Identity(1,1)   NOT NULL,
        [IFD_ID_IFM]       bigint                         NOT NULL,
        [INR_ID]           Int                            NOT NULL,
        [INR_ID_INVOICE]   Int                                NULL,
        [INR_ID_DISTR]     Int                                NULL,
        [INR_ID_PERIOD]    Int                                NULL,
        [INR_GOOD]         VarChar(150)                       NULL,
        [INR_NAME]         VarChar(500)                   NOT NULL,
        [SYS_NAME]         VarChar(200)                       NULL,
        [SO_INV_UNIT]      VarChar(200)                       NULL,
        [SO_INV_OKEI]      VarChar(150)                       NULL,
        [INR_SUM]          Money                              NULL,
        [INR_ID_TAX]       SmallInt                           NULL,
        [INR_TNDS]         decimal                            NULL,
        [INR_SNDS]         Money                              NULL,
        [INR_SALL]         Money                              NULL,
        [INR_COUNT]        SmallInt                           NULL,
        [INR_RN]           SmallInt                           NULL,
        CONSTRAINT [PK_dbo.InvoiceFactDetailTable] PRIMARY KEY CLUSTERED ([IFD_ID]),
        CONSTRAINT [FK_dbo.InvoiceFactDetailTable(IFD_ID_IFM)_dbo.InvoiceFactMasterTable(IFM_ID)] FOREIGN KEY  ([IFD_ID_IFM]) REFERENCES [dbo].[InvoiceFactMasterTable] ([IFM_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceFactDetailTable(IFD_ID_IFM)] ON [dbo].[InvoiceFactDetailTable] ([IFD_ID_IFM] ASC);
GO
