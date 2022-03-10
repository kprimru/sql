USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[PersonalSalary]
(
        [PS_ID]               UniqueIdentifier      NOT NULL,
        [PS_ID_VENDOR]        UniqueIdentifier          NULL,
        [PS_ID_PERSONAL]      UniqueIdentifier      NOT NULL,
        [PS_DATE]             SmallDateTime             NULL,
        [PS_ID_PERIOD]        UniqueIdentifier      NOT NULL,
        [PS_SALARY]           Money                 NOT NULL,
        [PS_BOOK_NORM]        Bit                   NOT NULL,
        [PS_ID_COMPETITION]   UniqueIdentifier          NULL,
        [PS_CORRECT]          Money                 NOT NULL,
        [PS_COMMENT]          VarChar(Max)          NOT NULL,
        [PS_PAYED]            Bit                       NULL,
        [PS_ID_PAY]           UniqueIdentifier          NULL,
        [PS_DEBT]             Money                     NULL,
        [PS_LOCK]             Bit                   NOT NULL,
        CONSTRAINT [PK_Salary.PersonalSalary] PRIMARY KEY CLUSTERED ([PS_ID]),
        CONSTRAINT [FK_Salary.PersonalSalary(PS_ID_PERSONAL)_Salary.Personals(PERMS_ID)] FOREIGN KEY  ([PS_ID_PERSONAL]) REFERENCES [Personal].[Personals] ([PERMS_ID]),
        CONSTRAINT [FK_Salary.PersonalSalary(PS_ID_PERIOD)_Salary.Period(PRMS_ID)] FOREIGN KEY  ([PS_ID_PERIOD]) REFERENCES [Common].[Period] ([PRMS_ID]),
        CONSTRAINT [FK_Salary.PersonalSalary(PS_ID_COMPETITION)_Salary.Competition(CPMS_ID)] FOREIGN KEY  ([PS_ID_COMPETITION]) REFERENCES [Book].[Competition] ([CPMS_ID]),
        CONSTRAINT [FK_Salary.PersonalSalary(PS_ID_VENDOR)_Salary.Vendors(VDMS_ID)] FOREIGN KEY  ([PS_ID_VENDOR]) REFERENCES [Clients].[Vendors] ([VDMS_ID]),
        CONSTRAINT [FK_Salary.PersonalSalary(PS_ID_PAY)_Salary.Period(PRMS_ID)] FOREIGN KEY  ([PS_ID_PAY]) REFERENCES [Common].[Period] ([PRMS_ID])
);GO
