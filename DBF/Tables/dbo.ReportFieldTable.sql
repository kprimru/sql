USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportFieldTable]
(
        [RF_ID]        SmallInt       Identity(1,1)   NOT NULL,
        [RF_NAME]      VarChar(50)                    NOT NULL,
        [RF_CAPTION]   VarChar(100)                   NOT NULL,
        [RF_ORDER]     SmallInt                       NOT NULL,
        CONSTRAINT [PK_dbo.ReportFieldTable] PRIMARY KEY CLUSTERED ([RF_ID])
);GO
