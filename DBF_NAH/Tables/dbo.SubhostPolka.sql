USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostPolka]
(
        [ID]           Int        Identity(1,1)   NOT NULL,
        [ID_SUBHOST]   SmallInt                   NOT NULL,
        [ID_PERIOD]    SmallInt                   NOT NULL,
        [POLKA]        decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.SubhostPolka] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.SubhostPolka(ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.SubhostPolka(ID_SUBHOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID])
);GO
