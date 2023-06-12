USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillTable]
(
        [BL_ID]          Int        Identity(1,1)   NOT NULL,
        [BL_ID_CLIENT]   Int                        NOT NULL,
        [BL_ID_PERIOD]   SmallInt                   NOT NULL,
        [BL_ID_ORG]      SmallInt                   NOT NULL,
        [BL_ID_PAYER]    Int                            NULL,
        CONSTRAINT [PK_dbo.BillTable] PRIMARY KEY NONCLUSTERED ([BL_ID]),
        CONSTRAINT [FK_dbo.BillTable(BL_ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([BL_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.BillTable(BL_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([BL_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.BillTable(BL_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([BL_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.BillTable(BL_ID_CLIENT,BL_ID_PERIOD)] ON [dbo].[BillTable] ([BL_ID_CLIENT] ASC, [BL_ID_PERIOD] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BillTable(BL_ID_PERIOD,BL_ID_CLIENT)+(BL_ID,BL_ID_ORG,BL_ID_PAYER)] ON [dbo].[BillTable] ([BL_ID_PERIOD] ASC, [BL_ID_CLIENT] ASC) INCLUDE ([BL_ID], [BL_ID_ORG], [BL_ID_PAYER]);
GO
