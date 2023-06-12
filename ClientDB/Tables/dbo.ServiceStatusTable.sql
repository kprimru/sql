USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceStatusTable]
(
        [ServiceStatusID]      Int            Identity(1,1)   NOT NULL,
        [ServiceStatusName]    VarChar(50)                    NOT NULL,
        [ServiceStatusReg]     SmallInt                           NULL,
        [ServiceStatusIndex]   Int                                NULL,
        [ServiceDefault]       Int                                NULL,
        [ServiceCode]          VarChar(100)                       NULL,
        CONSTRAINT [PK_dbo.ServiceStatusTable] PRIMARY KEY CLUSTERED ([ServiceStatusID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ServiceStatusTable(ServiceCode)] ON [dbo].[ServiceStatusTable] ([ServiceCode] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ServiceStatusTable(ServiceStatusName)] ON [dbo].[ServiceStatusTable] ([ServiceStatusName] ASC);
GO
GRANT SELECT ON [dbo].[ServiceStatusTable] TO BL_ADMIN;
GRANT SELECT ON [dbo].[ServiceStatusTable] TO BL_EDITOR;
GRANT SELECT ON [dbo].[ServiceStatusTable] TO BL_PARAM;
GRANT SELECT ON [dbo].[ServiceStatusTable] TO BL_READER;
GRANT SELECT ON [dbo].[ServiceStatusTable] TO BL_RGT;
GRANT SELECT ON [dbo].[ServiceStatusTable] TO claim_view;
GO
