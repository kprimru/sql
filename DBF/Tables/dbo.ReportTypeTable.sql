USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportTypeTable]
(
        [RTY_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [RTY_NAME]     VarChar(50)                   NOT NULL,
        [RTY_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.ReportTypeTable] PRIMARY KEY CLUSTERED ([RTY_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ReportTypeTable()] ON [dbo].[ReportTypeTable] ([RTY_NAME] ASC);
GO
