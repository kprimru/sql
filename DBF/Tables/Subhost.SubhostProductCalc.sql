USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostProductCalc]
(
        [SPC_ID]           Int        Identity(1,1)   NOT NULL,
        [SPC_ID_SUBHOST]   SmallInt                   NOT NULL,
        [SPC_ID_PERIOD]    SmallInt                   NOT NULL,
        [SPC_ID_PROD]      SmallInt                   NOT NULL,
        [SPC_COUNT]        SmallInt                   NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostProductCalc] PRIMARY KEY CLUSTERED ([SPC_ID]),
        CONSTRAINT [FK_Subhost.SubhostProductCalc(SPC_ID_SUBHOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SPC_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostProductCalc(SPC_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SPC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_Subhost.SubhostProductCalc(SPC_ID_PROD)_Subhost.SubhostProduct(SP_ID)] FOREIGN KEY  ([SPC_ID_PROD]) REFERENCES [Subhost].[SubhostProduct] ([SP_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Subhost.SubhostProductCalc(SPC_ID_SUBHOST,SPC_ID_PERIOD)+(SPC_ID_PROD,SPC_COUNT)] ON [Subhost].[SubhostProductCalc] ([SPC_ID_SUBHOST] ASC, [SPC_ID_PERIOD] ASC) INCLUDE ([SPC_ID_PROD], [SPC_COUNT]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostProductCalc(SPC_ID_PERIOD,SPC_ID_PROD,SPC_ID_SUBHOST)] ON [Subhost].[SubhostProductCalc] ([SPC_ID_PERIOD] ASC, [SPC_ID_PROD] ASC, [SPC_ID_SUBHOST] ASC);
GO
