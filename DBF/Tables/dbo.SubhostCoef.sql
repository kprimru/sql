USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostCoef]
(
        [SC_ID]           Int        Identity(1,1)   NOT NULL,
        [SC_ID_SUBHOST]   SmallInt                   NOT NULL,
        [SC_ID_PERIOD]    SmallInt                   NOT NULL,
        [SC_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.SubhostCoef] PRIMARY KEY CLUSTERED ([SC_ID]),
        CONSTRAINT [FK_dbo.SubhostCoef(SC_ID_SUBHOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([SC_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.SubhostCoef(SC_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([SC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
