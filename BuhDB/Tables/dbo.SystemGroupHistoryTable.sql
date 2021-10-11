USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemGroupHistoryTable]
(
        [ID]                 Int            Identity(1,1)   NOT NULL,
        [SystemGroupID]      Int                            NOT NULL,
        [SystemGroupName]    VarChar(100)                   NOT NULL,
        [SystemGroupOrder]   Int                            NOT NULL,
        [GroupPriceDate]     VarChar(20)                    NOT NULL,
        CONSTRAINT [PK_dbo.SystemGroupHistoryTable] PRIMARY KEY CLUSTERED ([ID])
);GO
GRANT DELETE ON [dbo].[SystemGroupHistoryTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[SystemGroupHistoryTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemGroupHistoryTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[SystemGroupHistoryTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemGroupHistoryTable] TO DBCount;
GRANT DELETE ON [dbo].[SystemGroupHistoryTable] TO DBPrice;
GRANT INSERT ON [dbo].[SystemGroupHistoryTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemGroupHistoryTable] TO DBPrice;
GRANT UPDATE ON [dbo].[SystemGroupHistoryTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemGroupHistoryTable] TO DBPriceReader;
GO
