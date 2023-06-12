USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostKBUTable]
(
        [SK_ID]          SmallInt   Identity(1,1)   NOT NULL,
        [SK_ID_HOST]     SmallInt                   NOT NULL,
        [SK_ID_PERIOD]   SmallInt                       NULL,
        [SK_ID_SYSTEM]   SmallInt                   NOT NULL,
        [SK_KBU]         decimal                    NOT NULL,
        [SK_ACTIVE]      Bit                        NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostKBUTable] PRIMARY KEY CLUSTERED ([SK_ID]),
        CONSTRAINT [FK_Subhost.SubhostKBUTable(SK_ID_HOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SK_ID_HOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostKBUTable(SK_ID_SYSTEM)_Subhost.SystemTable(SYS_ID)] FOREIGN KEY  ([SK_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostKBUTable(SK_ID_HOST,SK_ID_SYSTEM,SK_ID_PERIOD)] ON [Subhost].[SubhostKBUTable] ([SK_ID_HOST] ASC, [SK_ID_SYSTEM] ASC, [SK_ID_PERIOD] ASC);
GO
