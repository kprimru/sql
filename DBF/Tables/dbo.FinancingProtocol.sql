USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancingProtocol]
(
        [ID]            bigint          Identity(1,1)   NOT NULL,
        [ID_CLIENT]     Int                                 NULL,
        [ID_DOCUMENT]   Int                                 NULL,
        [TP]            VarChar(64)                     NOT NULL,
        [OPER]          VarChar(128)                    NOT NULL,
        [TXT]           VarChar(Max)                        NULL,
        [USR_NAME]      NVarChar(256)                   NOT NULL,
        [UPD_DATE]      DateTime                        NOT NULL,
        CONSTRAINT [PK_dbo.FinancingProtocol] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.FinancingProtocol(ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.FinancingProtocol(ID_CLIENT)+(ID_DOCUMENT,TP,OPER,TXT,USR_NAME,UPD_DATE,ID)] ON [dbo].[FinancingProtocol] ([ID_CLIENT] ASC) INCLUDE ([ID_DOCUMENT], [TP], [OPER], [TXT], [USR_NAME], [UPD_DATE], [ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.FinancingProtocol(ID_DOCUMENT,TP)+(OPER,TXT,USR_NAME,UPD_DATE)] ON [dbo].[FinancingProtocol] ([ID_DOCUMENT] ASC, [TP] ASC) INCLUDE ([OPER], [TXT], [USR_NAME], [UPD_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.FinancingProtocol(UPD_DATE)+(ID_CLIENT,ID_DOCUMENT,TP,OPER,TXT,USR_NAME)] ON [dbo].[FinancingProtocol] ([UPD_DATE] ASC) INCLUDE ([ID_CLIENT], [ID_DOCUMENT], [TP], [OPER], [TXT], [USR_NAME]);
GO
