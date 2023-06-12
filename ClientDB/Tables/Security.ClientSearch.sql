USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[ClientSearch]
(
        [CS_ID]       UniqueIdentifier      NOT NULL,
        [CS_TYPE]     VarChar(64)           NOT NULL,
        [CS_USER]     NVarChar(256)         NOT NULL,
        [CS_HOST]     NVarChar(256)         NOT NULL,
        [CS_DATE]     DateTime              NOT NULL,
        [CS_SHORT]    VarChar(250)          NOT NULL,
        [CS_SEARCH]   xml                       NULL,
        [CS_FREEZE]   Bit                   NOT NULL,
        CONSTRAINT [PK_Security.ClientSearch] PRIMARY KEY CLUSTERED ([CS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Security.ClientSearch(CS_USER,CS_HOST,CS_TYPE,CS_FREEZE)+(CS_ID,CS_SHORT,CS_DATE)] ON [Security].[ClientSearch] ([CS_USER] ASC, [CS_HOST] ASC, [CS_TYPE] ASC, [CS_FREEZE] ASC) INCLUDE ([CS_ID], [CS_SHORT], [CS_DATE]);
GO
