USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[ClientList]
(
        [LST_ID]        Int             Identity(1,1)   NOT NULL,
        [LST_TYPE]      VarChar(50)                     NOT NULL,
        [LST_USER]      NVarChar(256)                   NOT NULL,
        [LST_ALL]       Bit                             NOT NULL,
        [LST_MANAGER]   Bit                             NOT NULL,
        [LST_SERVICE]   Bit                             NOT NULL,
        [LST_ORI]       Bit                             NOT NULL,
        [LST_INCLUDE]   xml                                 NULL,
        [LST_EXCLUDE]   xml                                 NULL,
        CONSTRAINT [PK_Security.ClientList] PRIMARY KEY CLUSTERED ([LST_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Security.ClientList(LST_TYPE,LST_USER)+(LST_ALL,LST_MANAGER,LST_SERVICE,LST_ORI)] ON [Security].[ClientList] ([LST_TYPE] ASC, [LST_USER] ASC) INCLUDE ([LST_ALL], [LST_MANAGER], [LST_SERVICE], [LST_ORI]);
GO
