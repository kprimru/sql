USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemGroupTable]
(
        [SystemGroupID]      Int            Identity(1,1)   NOT NULL,
        [SystemGroupName]    VarChar(100)                   NOT NULL,
        [SystemGroupOrder]   Int                            NOT NULL,
        CONSTRAINT [PK_dbo.SystemGroupTable] PRIMARY KEY CLUSTERED ([SystemGroupID])
);GO
GRANT DELETE ON [dbo].[SystemGroupTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[SystemGroupTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemGroupTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[SystemGroupTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemGroupTable] TO DBCount;
GRANT DELETE ON [dbo].[SystemGroupTable] TO DBPrice;
GRANT INSERT ON [dbo].[SystemGroupTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemGroupTable] TO DBPrice;
GRANT UPDATE ON [dbo].[SystemGroupTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemGroupTable] TO DBPriceReader;
GO
