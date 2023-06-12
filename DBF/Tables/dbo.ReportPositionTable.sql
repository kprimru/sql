USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportPositionTable]
(
        [RP_ID]       TinyInt        Identity(1,1)   NOT NULL,
        [RP_NAME]     VarChar(100)                   NOT NULL,
        [RP_PSEDO]    VarChar(50)                    NOT NULL,
        [RP_ACTIVE]   Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.ReportPositionTable] PRIMARY KEY CLUSTERED ([RP_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ReportPositionTable(RP_NAME)] ON [dbo].[ReportPositionTable] ([RP_NAME] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ReportPositionTable(RP_PSEDO)] ON [dbo].[ReportPositionTable] ([RP_PSEDO] ASC);
GO
