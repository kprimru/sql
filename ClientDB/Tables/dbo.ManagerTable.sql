USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ManagerTable]
(
        [ManagerID]         Int            Identity(1,1)   NOT NULL,
        [ManagerName]       VarChar(250)                   NOT NULL,
        [ManagerPassword]   VarChar(50)                        NULL,
        [ManagerLogin]      VarChar(50)                    NOT NULL,
        [ManagerFullName]   VarChar(250)                       NULL,
        [ManagerEmail]      VarChar(50)                        NULL,
        [ManagerDomain]     VarChar(50)                        NULL,
        [ManagerLocal]      Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.ManagerTable] PRIMARY KEY CLUSTERED ([ManagerID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ManagerTable(ManagerLogin)] ON [dbo].[ManagerTable] ([ManagerLogin] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ManagerTable(ManagerName)] ON [dbo].[ManagerTable] ([ManagerName] ASC);
GO
GRANT SELECT ON [dbo].[ManagerTable] TO BL_ADMIN;
GRANT SELECT ON [dbo].[ManagerTable] TO BL_EDITOR;
GRANT SELECT ON [dbo].[ManagerTable] TO BL_PARAM;
GRANT SELECT ON [dbo].[ManagerTable] TO BL_READER;
GRANT SELECT ON [dbo].[ManagerTable] TO BL_RGT;
GRANT SELECT ON [dbo].[ManagerTable] TO claim_view;
GO
