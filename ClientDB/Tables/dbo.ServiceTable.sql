USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceTable]
(
        [ServiceID]           Int             Identity(1,1)   NOT NULL,
        [ServiceName]         VarChar(100)                    NOT NULL,
        [ServicePassword]     VarChar(50)                         NULL,
        [ServicePositionID]   Int                             NOT NULL,
        [ManagerID]           Int                             NOT NULL,
        [ServicePhone]        VarChar(100)                        NULL,
        [ServiceLogin]        VarChar(50)                     NOT NULL,
        [ServiceFullName]     VarChar(250)                        NULL,
        [ServiceDismiss]      SmallDateTime                       NULL,
        [ServiceFirst]        DateTime                            NULL,
        CONSTRAINT [PK_dbo.ServiceTable] PRIMARY KEY CLUSTERED ([ServiceID]),
        CONSTRAINT [FK_dbo.ServiceTable(ServicePositionID)_dbo.ServicePositionTable(ServicePositionID)] FOREIGN KEY  ([ServicePositionID]) REFERENCES [dbo].[ServicePositionTable] ([ServicePositionID]),
        CONSTRAINT [FK_dbo.ServiceTable(ManagerID)_dbo.ManagerTable(ManagerID)] FOREIGN KEY  ([ManagerID]) REFERENCES [dbo].[ManagerTable] ([ManagerID])
);
GO
GRANT SELECT ON [dbo].[ServiceTable] TO BL_ADMIN;
GRANT SELECT ON [dbo].[ServiceTable] TO BL_EDITOR;
GRANT SELECT ON [dbo].[ServiceTable] TO BL_PARAM;
GRANT SELECT ON [dbo].[ServiceTable] TO BL_READER;
GRANT SELECT ON [dbo].[ServiceTable] TO BL_RGT;
GRANT SELECT ON [dbo].[ServiceTable] TO claim_view;
GO
