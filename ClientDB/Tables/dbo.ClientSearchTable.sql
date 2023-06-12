USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientSearchTable]
(
        [ClientSearchID]    bigint          Identity(1,1)   NOT NULL,
        [ClientID]          Int                             NOT NULL,
        [SearchText]        VarChar(1024)                   NOT NULL,
        [SearchDate]        DateTime                        NOT NULL,
        [SearchDay]          AS ([dbo].[DateOf]([SearchDate])) PERSISTED,
        [SearchMonth]        AS ([dbo].[MonthString]([SearchDate])) PERSISTED,
        [SearchMonthDate]    AS ([dbo].[MonthOf]([SearchDate])) PERSISTED,
        [SearchGet]         DateTime                            NULL,
        [SearchGetDay]       AS ([dbo].[DateOf]([SearchGet])) PERSISTED,
        [SearchGetMonth]     AS ([dbo].[MonthOf]([SearchGet])) PERSISTED,
        CONSTRAINT [PK_dbo.ClientSearchTable] PRIMARY KEY NONCLUSTERED ([ClientSearchID]),
        CONSTRAINT [FK_dbo.ClientSearchTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientSearchTable(ClientID,SearchDate)] ON [dbo].[ClientSearchTable] ([ClientID] ASC, [SearchDate] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientSearchTable(ClientID,SearchGetDay)] ON [dbo].[ClientSearchTable] ([ClientID] ASC, [SearchGetDay] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientSearchTable(ClientID,SearchMonth)+(SearchDay,SearchText,SearchGet)] ON [dbo].[ClientSearchTable] ([ClientID] ASC, [SearchMonth] ASC) INCLUDE ([SearchDay], [SearchText], [SearchGet]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientSearchTable(SearchDay)+(ClientID,SearchMonthDate)] ON [dbo].[ClientSearchTable] ([SearchDay] ASC) INCLUDE ([ClientID], [SearchMonthDate]);
GO
