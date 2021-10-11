USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountFoundingTable]
(
        [CountFoundingID]           Int            Identity(1,1)   NOT NULL,
        [CountFoundingName]         VarChar(50)                    NOT NULL,
        [CountFoundingStr]          VarChar(150)                   NOT NULL,
        [CountFoundingServiceStr]   VarChar(150)                   NOT NULL,
        [CountFoundingOnlineStr]    VarChar(150)                       NULL,
        [EdIzm]                     VarChar(20)                    NOT NULL,
        [MonthCount]                Int                            NOT NULL,
        CONSTRAINT [PK_dbo.CountFoundingTable] PRIMARY KEY CLUSTERED ([CountFoundingID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.CountFoundingTable(CountFoundingName)] ON [dbo].[CountFoundingTable] ([CountFoundingName] ASC);
GO
GRANT DELETE ON [dbo].[CountFoundingTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[CountFoundingTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[CountFoundingTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[CountFoundingTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[CountFoundingTable] TO DBCount;
GRANT INSERT ON [dbo].[CountFoundingTable] TO DBCount;
GRANT SELECT ON [dbo].[CountFoundingTable] TO DBCount;
GRANT UPDATE ON [dbo].[CountFoundingTable] TO DBCount;
GO
