USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[___SubhostKBUTable]
(
        [SK_ID]          SmallInt   Identity(1,1)   NOT NULL,
        [SK_ID_HOST]     SmallInt                   NOT NULL,
        [SK_ID_SYSTEM]   SmallInt                   NOT NULL,
        [SK_ID_PERIOD]   SmallInt                   NOT NULL,
        [SK_KBU]         decimal                    NOT NULL,
        [SK_ACTIVE]      Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.___SubhostKBUTable] PRIMARY KEY CLUSTERED ([SK_ID]),
        CONSTRAINT [FK_dbo.___SubhostKBUTable(SK_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([SK_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_dbo.___SubhostKBUTable(SK_ID_HOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([SK_ID_HOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.___SubhostKBUTable(SK_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([SK_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
