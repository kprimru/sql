USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[SalaryCondition]
(
        [SCMS_ID]     UniqueIdentifier      NOT NULL,
        [SCMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_SalaryCondition] PRIMARY KEY CLUSTERED ([SCMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_SCMS_LAST] ON [Salary].[SalaryCondition] ([SCMS_LAST] DESC);
GO
