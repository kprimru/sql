USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[RoleGroup]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(512)         NOT NULL,
        [CAPTION]   NVarChar(512)         NOT NULL,
        [NOTE]      NVarChar(Max)         NOT NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Security.RoleGroup] PRIMARY KEY CLUSTERED ([ID])
);
GO
