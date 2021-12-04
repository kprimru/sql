USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActTable]
(
        [ACT_ID]           Int             Identity(1,1)   NOT NULL,
        [ACT_ID_MASTER]    Int                                 NULL,
        [ACT_DATE]         SmallDateTime                   NOT NULL,
        [ACT_ID_CLIENT]    Int                             NOT NULL,
        [ACT_ID_ORG]       SmallInt                        NOT NULL,
        [ACT_ID_INVOICE]   Int                                 NULL,
        [ACT_CLOSE_DATE]   SmallDateTime                       NULL,
        [ACT_SIGN]         SmallDateTime                       NULL,
        [ACT_PRINT]        Bit                                 NULL,
        [ACT_PRINT_DATE]   DateTime                            NULL,
        [ACT_ID_COUR]      SmallInt                            NULL,
        [ACT_TO]           Bit                                 NULL,
        [ACT_ID_PAYER]     Int                                 NULL,
        [ACT_STATUS]       TinyInt                         NOT NULL,
        [ACT_UPD_DATE]     DateTime                        NOT NULL,
        [ACT_UPD_USER]     NVarChar(258)                   NOT NULL,
        [IsOnline]         Bit                                 NULL,
        [IsLongService]    Bit                                 NULL,
        CONSTRAINT [PK_dbo.ActTable] PRIMARY KEY NONCLUSTERED ([ACT_ID]),
        CONSTRAINT [FK_dbo.ActTable(ACT_ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([ACT_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.ActTable(ACT_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([ACT_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.ActTable(ACT_ID_INVOICE)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([ACT_ID_INVOICE]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID]),
        CONSTRAINT [FK_dbo.ActTable(ACT_ID_COUR)_dbo.CourierTable(COUR_ID)] FOREIGN KEY  ([ACT_ID_COUR]) REFERENCES [dbo].[CourierTable] ([COUR_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ActTable(ACT_ID_CLIENT,ACT_ID,ACT_DATE)] ON [dbo].[ActTable] ([ACT_ID_CLIENT] ASC, [ACT_ID] ASC, [ACT_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ActTable(ACT_DATE)+(ACT_ID,ACT_ID_CLIENT,ACT_ID_ORG)] ON [dbo].[ActTable] ([ACT_DATE] ASC) INCLUDE ([ACT_ID], [ACT_ID_CLIENT], [ACT_ID_ORG]);
CREATE NONCLUSTERED INDEX [IX_dbo.ActTable(ACT_DATE,ACT_PRINT,ACT_SIGN)+(ACT_ID,ACT_ID_CLIENT)] ON [dbo].[ActTable] ([ACT_DATE] ASC, [ACT_PRINT] ASC, [ACT_SIGN] ASC) INCLUDE ([ACT_ID], [ACT_ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ActTable(ACT_ID_INVOICE)+(ACT_ID)] ON [dbo].[ActTable] ([ACT_ID_INVOICE] ASC) INCLUDE ([ACT_ID]);
GO
