USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostLessonPrice]
(
        [SLP_ID]          Int        Identity(1,1)   NOT NULL,
        [SLP_ID_PERIOD]   SmallInt                   NOT NULL,
        [SLP_ID_LESSON]   SmallInt                   NOT NULL,
        [SLP_PRICE]       Money                      NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostLessonPrice] PRIMARY KEY CLUSTERED ([SLP_ID]),
        CONSTRAINT [FK_Subhost.SubhostLessonPrice(SLP_ID_LESSON)_Subhost.Lesson(LS_ID)] FOREIGN KEY  ([SLP_ID_LESSON]) REFERENCES [Subhost].[Lesson] ([LS_ID]),
        CONSTRAINT [FK_Subhost.SubhostLessonPrice(SLP_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SLP_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Subhost.SubhostLessonPrice(SLP_ID_LESSON,SLP_ID_PERIOD)] ON [Subhost].[SubhostLessonPrice] ([SLP_ID_LESSON] ASC, [SLP_ID_PERIOD] ASC);
GO
