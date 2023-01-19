USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[PersonalSalaryBook]
(
        [PSB_ID]          UniqueIdentifier      NOT NULL,
        [PSB_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [PSB_ID_IB]       UniqueIdentifier      NOT NULL,
        [PSB_SUM]         Money                 NOT NULL,
        [PSB_PERCENT]     decimal               NOT NULL,
        [PSB_COUNT]       TinyInt               NOT NULL,
        [PSB_TOTAL]       Money                 NOT NULL,
        [PSB_DELIVERY]    Money                 NOT NULL,
        [PSB_PAYED]       Bit                   NOT NULL,
        CONSTRAINT [PK_Salary.PersonalSalaryBook] PRIMARY KEY CLUSTERED ([PSB_ID]),
        CONSTRAINT [FK_Salary.PersonalSalaryBook(PSB_ID_MASTER)_Salary.PersonalSalary(PS_ID)] FOREIGN KEY  ([PSB_ID_MASTER]) REFERENCES [Salary].[PersonalSalary] ([PS_ID]),
        CONSTRAINT [FK_Salary.PersonalSalaryBook(PSB_ID_IB)_Salary.IncomeBook(IB_ID)] FOREIGN KEY  ([PSB_ID_IB]) REFERENCES [Income].[IncomeBook] ([IB_ID])
);
GO
