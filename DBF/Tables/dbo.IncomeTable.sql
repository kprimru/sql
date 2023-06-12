USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncomeTable]
(
        [IN_ID]           Int             Identity(1,1)   NOT NULL,
        [IN_ID_MASTER]    Int                                 NULL,
        [IN_ID_CLIENT]    Int                             NOT NULL,
        [IN_ID_ORG]       SmallInt                        NOT NULL,
        [IN_DATE]         SmallDateTime                   NOT NULL,
        [IN_SUM]          Money                           NOT NULL,
        [IN_PAY_DATE]     SmallDateTime                   NOT NULL,
        [IN_PAY_NUM]      VarChar(50)                     NOT NULL,
        [IN_ID_INVOICE]   Int                                 NULL,
        [IN_PRIMARY]      Bit                                 NULL,
        [IN_ID_IT]        SmallInt                            NULL,
        [IN_ID_PAYER]     Int                                 NULL,
        [IN_STATUS]       TinyInt                         NOT NULL,
        [IN_UPD_DATE]     DateTime                        NOT NULL,
        [IN_UPD_USER]     NVarChar(256)                   NOT NULL,
        [Raw_Id]          bigint                              NULL,
        CONSTRAINT [PK_dbo.IncomeTable] PRIMARY KEY NONCLUSTERED ([IN_ID]),
        CONSTRAINT [FK_dbo.IncomeTable(IN_ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([IN_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.IncomeTable(IN_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([IN_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.IncomeTable(IN_ID_IT)_dbo.IncomeTypeTable(IT_ID)] FOREIGN KEY  ([IN_ID_IT]) REFERENCES [dbo].[IncomeTypeTable] ([IT_ID]),
        CONSTRAINT [FK_dbo.IncomeTable(IN_ID_INVOICE)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([IN_ID_INVOICE]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.IncomeTable(IN_ID_CLIENT,IN_ID)] ON [dbo].[IncomeTable] ([IN_ID_CLIENT] ASC, [IN_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.IncomeTable(IN_DATE)+(IN_ID_ORG,IN_PAY_NUM,Raw_Id)] ON [dbo].[IncomeTable] ([IN_DATE] ASC) INCLUDE ([IN_ID_ORG], [IN_PAY_NUM], [Raw_Id]);
CREATE NONCLUSTERED INDEX [IX_dbo.IncomeTable(IN_ID_INVOICE,IN_DATE,IN_SUM)] ON [dbo].[IncomeTable] ([IN_ID_INVOICE] DESC, [IN_DATE] ASC, [IN_SUM] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.IncomeTable(Raw_Id)] ON [dbo].[IncomeTable] ([Raw_Id] ASC);
GO
GRANT SELECT ON [dbo].[IncomeTable] TO rl_all_r;
GO
