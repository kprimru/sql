USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportHistoryFieldTable]
(
        [RHF_ID]        SmallInt       Identity(1,1)   NOT NULL,
        [RHF_NAME]      VarChar(50)                    NOT NULL,
        [RHF_CAPTION]   VarChar(100)                   NOT NULL,
        [RHF_ORDER]     SmallInt                       NOT NULL,
        CONSTRAINT [PK_dbo.ReportHistoryFieldTable] PRIMARY KEY CLUSTERED ([RHF_ID])
);GO
