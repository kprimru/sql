USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[SystemPrice]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]   Int                   NOT NULL,
        [ID_MONTH]    UniqueIdentifier      NOT NULL,
        [PRICE]       Money                 NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        CONSTRAINT [PK_Price.SystemPrice] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Price.SystemPrice(ID_MONTH)_Price.Period(ID)] FOREIGN KEY  ([ID_MONTH]) REFERENCES [Common].[Period] ([ID]),
        CONSTRAINT [FK_Price.SystemPrice(ID_SYSTEM)_Price.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Price.SystemPrice(ID_MONTH,ID_SYSTEM)+(PRICE)] ON [Price].[SystemPrice] ([ID_MONTH] ASC, [ID_SYSTEM] ASC) INCLUDE ([PRICE]);
CREATE NONCLUSTERED INDEX [IX_Price.SystemPrice(ID_SYSTEM)+(ID_MONTH,PRICE)] ON [Price].[SystemPrice] ([ID_SYSTEM] ASC) INCLUDE ([ID_MONTH], [PRICE]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Price.SystemPrice(ID_SYSTEM,ID_MONTH)] ON [Price].[SystemPrice] ([ID_SYSTEM] ASC, [ID_MONTH] ASC);
GO
