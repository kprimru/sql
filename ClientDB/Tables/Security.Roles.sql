USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Roles]
(
        [RoleID]         Int            Identity(1,1)   NOT NULL,
        [RoleMasterID]   Int                                NULL,
        [RoleName]       VarChar(50)                        NULL,
        [RoleCaption]    VarChar(50)                    NOT NULL,
        [RoleNote]       VarChar(Max)                       NULL,
        CONSTRAINT [PK_Security.Roles] PRIMARY KEY CLUSTERED ([RoleID]),
        CONSTRAINT [FK_Security.Roles(RoleMasterID)_Security.Roles(RoleID)] FOREIGN KEY  ([RoleMasterID]) REFERENCES [Security].[Roles] ([RoleID])
);GO
