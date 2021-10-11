USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[PersonalSalaryDetail]
(
        [PSD_ID]          UniqueIdentifier      NOT NULL,
        [PSD_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [PSD_ID_INCOME]   UniqueIdentifier      NOT NULL,
        [PSD_SUM]         Money                 NOT NULL,
        [PSD_PRICE]       Money                     NULL,
        [PSD_COUNT]       TinyInt               NOT NULL,
        [PSD_PERCENT]     decimal               NOT NULL,
        [PSD_MON]         TinyInt               NOT NULL,
        [PSD_TOTAL]       Money                 NOT NULL,
        [PSD_PAYED]       Bit                   NOT NULL,
        [PSD_SECOND]      Bit                       NULL,
        [PSD_PAY_DATE]    SmallDateTime             NULL,
        CONSTRAINT [PK_PersonalSalaryDetail] PRIMARY KEY CLUSTERED ([PSD_ID]),
        CONSTRAINT [FK_PersonalSalaryDetail_PersonalSalary] FOREIGN KEY  ([PSD_ID_MASTER]) REFERENCES [Salary].[PersonalSalary] ([PS_ID]),
        CONSTRAINT [FK_PersonalSalaryDetail_IncomeDetail] FOREIGN KEY  ([PSD_ID_INCOME]) REFERENCES [Income].[IncomeDetail] ([ID_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_PersonalSalaryDetail_PSD_ID_MASTER] ON [Salary].[PersonalSalaryDetail] ([PSD_ID_MASTER] ASC);
GO
