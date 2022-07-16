USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[Version]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [VERSION]    NVarChar(128)         NOT NULL,
        [STATUS]     TinyInt               NOT NULL,
        [UPD_DATE]   DateTime              NOT NULL,
        [UPD_USER]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Maintenance.Version] PRIMARY KEY CLUSTERED ([ID])
);GO
