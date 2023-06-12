USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[RoleMessages]
(
        [RM_ID]        UniqueIdentifier      NOT NULL,
        [RM_ID_ROLE]   UniqueIdentifier      NOT NULL,
        [RM_ID_USER]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Security.RoleMessages] PRIMARY KEY CLUSTERED ([RM_ID]),
        CONSTRAINT [FK_Security.RoleMessages(RM_ID_ROLE)_Security.Roles(RL_ID)] FOREIGN KEY  ([RM_ID_ROLE]) REFERENCES [Security].[Roles] ([RL_ID]),
        CONSTRAINT [FK_Security.RoleMessages(RM_ID_USER)_Security.Users(USMS_ID)] FOREIGN KEY  ([RM_ID_USER]) REFERENCES [Security].[Users] ([USMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Security.RoleMessages(RM_ID_ROLE)+(RM_ID_USER)] ON [Security].[RoleMessages] ([RM_ID_ROLE] ASC) INCLUDE ([RM_ID_USER]);
GO
