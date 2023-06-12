USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientPersonalTable]
(
        [PER_ID]              Int            Identity(1,1)   NOT NULL,
        [PER_ID_CLIENT]       Int                            NOT NULL,
        [PER_FAM]             VarChar(100)                       NULL,
        [PER_NAME]            VarChar(100)                       NULL,
        [PER_OTCH]            VarChar(100)                       NULL,
        [PER_ID_POS]          SmallInt                           NULL,
        [PER_ID_REPORT_POS]   TinyInt                        NOT NULL,
        CONSTRAINT [PK_dbo.ClientPersonalTable] PRIMARY KEY NONCLUSTERED ([PER_ID]),
        CONSTRAINT [FK_dbo.ClientPersonalTable(PER_ID_REPORT_POS)_dbo.ReportPositionTable(RP_ID)] FOREIGN KEY  ([PER_ID_REPORT_POS]) REFERENCES [dbo].[ReportPositionTable] ([RP_ID]),
        CONSTRAINT [FK_dbo.ClientPersonalTable(PER_ID_POS)_dbo.PositionTable(POS_ID)] FOREIGN KEY  ([PER_ID_POS]) REFERENCES [dbo].[PositionTable] ([POS_ID]),
        CONSTRAINT [FK_dbo.ClientPersonalTable(PER_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([PER_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientPersonalTable(PER_ID_CLIENT,PER_ID_REPORT_POS)] ON [dbo].[ClientPersonalTable] ([PER_ID_CLIENT] ASC, [PER_ID_REPORT_POS] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientPersonalTable(PER_ID_POS)] ON [dbo].[ClientPersonalTable] ([PER_ID_POS] ASC);
GO
