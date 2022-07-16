USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[Settings]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [MAINTENANCE_MODE]   Bit                   NOT NULL,
        [PROCEDURE_LOG]      Bit                   NOT NULL,
        [PROCEDURE_TIME]     Bit                   NOT NULL,
        [ERROR_LOG]          Bit                   NOT NULL,
        [ENABLED]            Bit                   NOT NULL,
        [FIAS]               NVarChar(1024)        NOT NULL,
        [STATUS]             TinyInt               NOT NULL,
        [UPD_USER]           NVarChar(256)         NOT NULL,
        [DATE]               DateTime              NOT NULL,
        CONSTRAINT [PK_Maintenance.Settings] PRIMARY KEY CLUSTERED ([ID])
);GO
