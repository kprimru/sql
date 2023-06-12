USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Income].[Incomes]
(
        [IN_ID]          UniqueIdentifier      NOT NULL,
        [IN_ID_INCOME]   UniqueIdentifier          NULL,
        [IN_ID_CLIENT]   UniqueIdentifier      NOT NULL,
        [IN_DATE]        SmallDateTime         NOT NULL,
        [IN_PAY]         VarChar(50)               NULL,
        [IN_ID_VENDOR]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Income.Incomes] PRIMARY KEY CLUSTERED ([IN_ID]),
        CONSTRAINT [FK_Income.Incomes(IN_ID_CLIENT)_Income.Clients(CLMS_ID)] FOREIGN KEY  ([IN_ID_CLIENT]) REFERENCES [Clients].[Clients] ([CLMS_ID]),
        CONSTRAINT [FK_Income.Incomes(IN_ID_VENDOR)_Income.Vendors(VDMS_ID)] FOREIGN KEY  ([IN_ID_VENDOR]) REFERENCES [Clients].[Vendors] ([VDMS_ID]),
        CONSTRAINT [FK_Income.Incomes(IN_ID_INCOME)_Income.Incomes(IN_ID)] FOREIGN KEY  ([IN_ID_INCOME]) REFERENCES [Income].[Incomes] ([IN_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Income.Incomes(IN_ID)+(IN_ID_INCOME)] ON [Income].[Incomes] ([IN_ID] ASC) INCLUDE ([IN_ID_INCOME]);
CREATE NONCLUSTERED INDEX [IX_Income.Incomes(IN_ID_INCOME)+(IN_ID)] ON [Income].[Incomes] ([IN_ID_INCOME] ASC) INCLUDE ([IN_ID]);
GO
