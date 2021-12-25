USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[PeriodDetail]
(
        [PR_ID]           UniqueIdentifier      NOT NULL,
        [PR_ID_MASTER]    UniqueIdentifier      NOT NULL,
        [PR_NAME]         VarChar(50)           NOT NULL,
        [PR_BEGIN_DATE]   SmallDateTime         NOT NULL,
        [PR_END_DATE]     SmallDateTime         NOT NULL,
        [PR_DATE]         SmallDateTime         NOT NULL,
        [PR_END]          SmallDateTime             NULL,
        [PR_REF]          TinyInt               NOT NULL,
        CONSTRAINT [PK_Period] PRIMARY KEY CLUSTERED ([PR_ID]),
        CONSTRAINT [FK_Period_Period] FOREIGN KEY  ([PR_ID_MASTER]) REFERENCES [Common].[Period] ([PRMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_PERIOD_MASTER] ON [Common].[PeriodDetail] ([PR_ID_MASTER] ASC, [PR_BEGIN_DATE] ASC);
GO
