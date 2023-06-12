USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostNorm]
(
        [ID]           Int        Identity(1,1)   NOT NULL,
        [ID_SUBHOST]   SmallInt                   NOT NULL,
        [ID_PERIOD]    SmallInt                   NOT NULL,
        [NORM]         decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.SubhostNorm] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.SubhostNorm(ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.SubhostNorm(ID_SUBHOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID])
);
GO
