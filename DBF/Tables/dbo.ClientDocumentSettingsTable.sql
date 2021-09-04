USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDocumentSettingsTable]
(
        [CDS_ID]             Int            Identity(1,1)   NOT NULL,
        [CDS_ID_CLIENT]      Int                            NOT NULL,
        [CDS_ACT_CONTRACT]   VarChar(100)                   NOT NULL,
        [CDS_ACT_POS]        VarChar(200)                       NULL,
        [CDS_ACT_POS_F]      VarChar(200)                       NULL,
        [CDS_ACT_NAME]       VarChar(500)                   NOT NULL,
        [CDS_ACT_NAME_F]     VarChar(500)                   NOT NULL,
        [CDS_BILL_REST]      Bit                            NOT NULL,
        [CDS_INS_CONTRACT]   Bit                            NOT NULL,
        [CDS_INS_NAME]       VarChar(500)                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientDocumentSettingsTable] PRIMARY KEY CLUSTERED ([CDS_ID]),
        CONSTRAINT [FK_dbo.ClientDocumentSettingsTable(CDS_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([CDS_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ClientDocumentSettingsTable(CDS_ID_CLIENT)] ON [dbo].[ClientDocumentSettingsTable] ([CDS_ID_CLIENT] ASC);
GO
