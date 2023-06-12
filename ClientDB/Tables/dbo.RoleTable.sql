USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleTable]
(
        [RoleID]     Int           Identity(1,1)   NOT NULL,
        [RoleName]   VarChar(50)                   NOT NULL,
        [RoleStr]    VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.RoleTable] PRIMARY KEY CLUSTERED ([RoleID])
);
GO
GRANT SELECT ON [dbo].[RoleTable] TO DBAuditor;
GRANT SELECT ON [dbo].[RoleTable] TO DBChief;
GRANT SELECT ON [dbo].[RoleTable] TO DBQuality;
GRANT SELECT ON [dbo].[RoleTable] TO DBTech;
GO
