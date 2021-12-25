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
        CONSTRAINT [PK_RoleMessages] PRIMARY KEY CLUSTERED ([RM_ID]),
        CONSTRAINT [FK_RoleMessages_Roles] FOREIGN KEY  ([RM_ID_ROLE]) REFERENCES [Security].[Roles] ([RL_ID]),
        CONSTRAINT [FK_RoleMessages_Users] FOREIGN KEY  ([RM_ID_USER]) REFERENCES [Security].[Users] ([USMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_ROLE] ON [Security].[RoleMessages] ([RM_ID_ROLE] ASC) INCLUDE ([RM_ID_USER]);
GO
