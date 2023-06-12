USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[SalaryConditionDetail]
(
        [SC_ID]            UniqueIdentifier      NOT NULL,
        [SC_ID_MASTER]     UniqueIdentifier      NOT NULL,
        [SC_ID_PER_TYPE]   UniqueIdentifier      NOT NULL,
        [SC_WEIGHT]        decimal               NOT NULL,
        [SC_VALUE]         Money                 NOT NULL,
        [SC_DATE]          SmallDateTime         NOT NULL,
        [SC_END]           SmallDateTime             NULL,
        [SC_REF]           TinyInt               NOT NULL,
        CONSTRAINT [PK_Salary.SalaryConditionDetail] PRIMARY KEY CLUSTERED ([SC_ID]),
        CONSTRAINT [FK_Salary.SalaryConditionDetail(SC_ID_MASTER)_Salary.SalaryCondition(SCMS_ID)] FOREIGN KEY  ([SC_ID_MASTER]) REFERENCES [Salary].[SalaryCondition] ([SCMS_ID]),
        CONSTRAINT [FK_Salary.SalaryConditionDetail(SC_ID_PER_TYPE)_Salary.PersonalType(PTMS_ID)] FOREIGN KEY  ([SC_ID_PER_TYPE]) REFERENCES [Personal].[PersonalType] ([PTMS_ID])
);
GO
