USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportTemplateTable]
(
        [RT_ID]               SmallInt       Identity(1,1)   NOT NULL,
        [RT_NAME]             VarChar(150)                   NOT NULL,
        [RT_TEXT]             VarChar(Max)                       NULL,
        [RT_ID_REPORT_TYPE]   SmallInt                           NULL,
        [RT_LIST_STATUS]      VarChar(Max)                       NULL,
        [RT_LIST_SUBHOST]     VarChar(Max)                       NULL,
        [RT_LIST_SYSTEM]      VarChar(Max)                       NULL,
        [RT_LIST_SYSTYPE]     VarChar(Max)                       NULL,
        [RT_LIST_NETTYPE]     VarChar(Max)                       NULL,
        [RT_LIST_PERIOD]      VarChar(Max)                       NULL,
        [RT_LIST_TECHTYPE]    VarChar(Max)                       NULL,
        [RT_TOTALRIC]         Bit                                NULL,
        [RT_TOTALCOUNT]       Bit                                NULL,
        CONSTRAINT [PK_dbo.ReportTemplateTable] PRIMARY KEY CLUSTERED ([RT_ID]),
        CONSTRAINT [FK_dbo.ReportTemplateTable(RT_ID_REPORT_TYPE)_dbo.ReportTypeTable(RTY_ID)] FOREIGN KEY  ([RT_ID_REPORT_TYPE]) REFERENCES [dbo].[ReportTypeTable] ([RTY_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ReportTemplateTable()] ON [dbo].[ReportTemplateTable] ([RT_NAME] ASC);
GO
