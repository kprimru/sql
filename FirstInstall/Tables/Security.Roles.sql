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
        CONSTRAINT [PK_Security.Roles] PRIMARY KEY NONCLUSTERED ([RL_ID]),
        CONSTRAINT [FK_Security.Roles(RL_ID_MASTER)_Security.Roles(RL_ID)] FOREIGN KEY  ([RL_ID_MASTER]) REFERENCES [Security].[Roles] ([RL_ID])
);
GO
CREATE CLUSTERED INDEX [IC_Security.Roles(RL_ID_MASTER)] ON [Security].[Roles] ([RL_ID_MASTER] ASC);
CREATE NONCLUSTERED INDEX [IX_Security.Roles(RL_ROLE)+(RL_ID)] ON [Security].[Roles] ([RL_ROLE] ASC) INCLUDE ([RL_ID]);
GO
