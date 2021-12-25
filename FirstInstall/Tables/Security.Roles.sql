USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Roles]
(
        [RL_ID]          UniqueIdentifier      NOT NULL,
        [RL_ID_MASTER]   UniqueIdentifier          NULL,
        [RL_NAME]        VarChar(150)          NOT NULL,
        [RL_ROLE]        VarChar(50)           NOT NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY NONCLUSTERED ([RL_ID]),
        CONSTRAINT [FK_Roles_Roles] FOREIGN KEY  ([RL_ID_MASTER]) REFERENCES [Security].[Roles] ([RL_ID])
);
GO
CREATE CLUSTERED INDEX [IX_RL_MASTER] ON [Security].[Roles] ([RL_ID_MASTER] ASC);
CREATE NONCLUSTERED INDEX [IX_ROLE] ON [Security].[Roles] ([RL_ROLE] ASC) INCLUDE ([RL_ID]);
GO
