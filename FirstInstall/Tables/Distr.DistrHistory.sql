USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[DistrHistory]
(
        [DH_ID]          UniqueIdentifier      NOT NULL,
        [DH_ID_DISTR]    UniqueIdentifier      NOT NULL,
        [DH_ID_SYSTEM]   UniqueIdentifier      NOT NULL,
        [DH_ID_NET]      UniqueIdentifier      NOT NULL,
        [DH_ID_TYPE]     UniqueIdentifier      NOT NULL,
        [DH_ID_TECH]     UniqueIdentifier      NOT NULL,
        [DH_DATE]        SmallDateTime         NOT NULL,
        [DH_END]         SmallDateTime             NULL,
        [DH_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Distr.DistrHistory] PRIMARY KEY CLUSTERED ([DH_ID]),
        CONSTRAINT [FK_Distr.DistrHistory(DH_ID_TYPE)_Distr.DistrType(DTMS_ID)] FOREIGN KEY  ([DH_ID_TYPE]) REFERENCES [Distr].[DistrType] ([DTMS_ID]),
        CONSTRAINT [FK_Distr.DistrHistory(DH_ID_NET)_Distr.NetType(NTMS_ID)] FOREIGN KEY  ([DH_ID_NET]) REFERENCES [Distr].[NetType] ([NTMS_ID]),
        CONSTRAINT [FK_Distr.DistrHistory(DH_ID_SYSTEM)_Distr.Systems(SYSMS_ID)] FOREIGN KEY  ([DH_ID_SYSTEM]) REFERENCES [Distr].[Systems] ([SYSMS_ID]),
        CONSTRAINT [FK_Distr.DistrHistory(DH_ID_TECH)_Distr.TechType(TTMS_ID)] FOREIGN KEY  ([DH_ID_TECH]) REFERENCES [Distr].[TechType] ([TTMS_ID]),
        CONSTRAINT [FK_Distr.DistrHistory(DH_ID_DISTR)_Distr.DistrStore(DS_ID)] FOREIGN KEY  ([DH_ID_DISTR]) REFERENCES [Distr].[DistrStore] ([DS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Distr.DistrHistory(DH_ID_DISTR,DH_REF)+INCL] ON [Distr].[DistrHistory] ([DH_ID_DISTR] ASC, [DH_REF] ASC) INCLUDE ([DH_ID], [DH_ID_SYSTEM], [DH_ID_NET], [DH_ID_TYPE], [DH_ID_TECH], [DH_DATE], [DH_END]);
GO
