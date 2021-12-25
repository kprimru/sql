USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrServiceStatusTable]
(
        [DSS_ID]          SmallInt      Identity(1,1)   NOT NULL,
        [DSS_NAME]        VarChar(50)                   NOT NULL,
        [DSS_ID_STATUS]   SmallInt                          NULL,
        [DSS_SUBHOST]     Bit                               NULL,
        [DSS_REPORT]      Bit                           NOT NULL,
        [DSS_ACTIVE]      Bit                           NOT NULL,
        [DSS_OLD_CODE]    Int                               NULL,
        [DSS_WORK]        Bit                               NULL,
        [DSS_ORDER]       Int                               NULL,
        [DSS_ACT]         Bit                               NULL,
        CONSTRAINT [PK_dbo.DistrServiceStatusTable] PRIMARY KEY CLUSTERED ([DSS_ID]),
        CONSTRAINT [FK_dbo.DistrServiceStatusTable(DSS_ID_STATUS)_dbo.DistrStatusTable(DS_ID)] FOREIGN KEY  ([DSS_ID_STATUS]) REFERENCES [dbo].[DistrStatusTable] ([DS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.DistrServiceStatusTable()] ON [dbo].[DistrServiceStatusTable] ([DSS_NAME] ASC);
GO
