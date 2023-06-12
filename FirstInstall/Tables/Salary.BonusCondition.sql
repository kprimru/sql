USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[BonusCondition]
(
        [BCMS_ID]     UniqueIdentifier      NOT NULL,
        [BCMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Salary.BonusCondition] PRIMARY KEY CLUSTERED ([BCMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Salary.BonusCondition(BCMS_LAST)] ON [Salary].[BonusCondition] ([BCMS_LAST] DESC);
GO
