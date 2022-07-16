USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Protocol]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [TYPE]       NVarChar(128)         NOT NULL,
        [NOTE]       NVarChar(1024)        NOT NULL,
        [UPD_DATE]   DateTime              NOT NULL,
        [UPD_USER]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Security.Protocol] PRIMARY KEY CLUSTERED ([ID])
);GO
