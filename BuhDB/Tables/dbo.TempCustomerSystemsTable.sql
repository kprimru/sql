USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempCustomerSystemsTable]
(
        [ID]                    Int           Identity(1,1)   NOT NULL,
        [CustomerID]            Int                           NOT NULL,
        [SystemID]              Int                           NOT NULL,
        [DistrTypeID]           Int                           NOT NULL,
        [PriceAbonement]        Int                           NOT NULL,
        [DiscountRate]          decimal                       NOT NULL,
        [FixedSum]              Money                         NOT NULL,
        [BeginMonth]            Int                           NOT NULL,
        [MonthCount]            Int                           NOT NULL,
        [SystemPriceModeName]   VarChar(50)                   NOT NULL,
        [SystemSet]             Int                           NOT NULL,
        [MonthPrice]            Money                             NULL,,
        CONSTRAINT [FK_dbo.TempCustomerSystemsTable(SystemID)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([SystemID]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.TempCustomerSystemsTable(CustomerID)_dbo.CustomerTable(CustomerID)] FOREIGN KEY  ([CustomerID]) REFERENCES [dbo].[CustomerTable] ([CustomerID]),
        CONSTRAINT [FK_dbo.TempCustomerSystemsTable(DistrTypeID)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([DistrTypeID]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.TempCustomerSystemsTable+COL+INCL] ON [dbo].[TempCustomerSystemsTable] ([CustomerID] ASC, [DistrTypeID] ASC, [SystemID] ASC, [PriceAbonement] ASC, [DiscountRate] ASC, [FixedSum] ASC, [BeginMonth] ASC, [MonthCount] ASC, [SystemPriceModeName] ASC, [SystemSet] ASC);
GO
GRANT DELETE ON [dbo].[TempCustomerSystemsTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[TempCustomerSystemsTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[TempCustomerSystemsTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[TempCustomerSystemsTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[TempCustomerSystemsTable] TO DBCount;
GRANT INSERT ON [dbo].[TempCustomerSystemsTable] TO DBCount;
GRANT SELECT ON [dbo].[TempCustomerSystemsTable] TO DBCount;
GRANT UPDATE ON [dbo].[TempCustomerSystemsTable] TO DBCount;
GO
