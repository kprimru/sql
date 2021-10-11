USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostStudy]
(
        [SS_ID]           Int        Identity(1,1)   NOT NULL,
        [SS_ID_PERIOD]    SmallInt                   NOT NULL,
        [SS_ID_SUBHOST]   SmallInt                   NOT NULL,
        [SS_ID_LESSON]    SmallInt                   NOT NULL,
        [SS_COUNT]        TinyInt                    NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostStudy] PRIMARY KEY CLUSTERED ([SS_ID]),
        CONSTRAINT [FK_Subhost.SubhostStudy(SS_ID_SUBHOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SS_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostStudy(SS_ID_LESSON)_Subhost.Lesson(LS_ID)] FOREIGN KEY  ([SS_ID_LESSON]) REFERENCES [Subhost].[Lesson] ([LS_ID]),
        CONSTRAINT [FK_Subhost.SubhostStudy(SS_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SS_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostStudy(SS_ID_PERIOD,SS_ID_SUBHOST,SS_ID_LESSON)] ON [Subhost].[SubhostStudy] ([SS_ID_PERIOD] ASC, [SS_ID_SUBHOST] ASC, [SS_ID_LESSON] ASC);
GO
