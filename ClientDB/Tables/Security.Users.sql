USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Users]
(
        [US_ID]      UniqueIdentifier      NOT NULL,
        [US_LOGIN]   NVarChar(256)         NOT NULL,
        [US_FULL]    NVarChar(1024)        NOT NULL,
        [US_SHORT]   NVarChar(256)         NOT NULL,
        [US_LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Security.Users] PRIMARY KEY CLUSTERED ([US_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Security.Users(US_LAST)] ON [Security].[Users] ([US_LAST] ASC);
CREATE NONCLUSTERED INDEX [IX_Security.Users(US_LOGIN)+(US_SHORT)] ON [Security].[Users] ([US_LOGIN] ASC) INCLUDE ([US_SHORT]);
GO
