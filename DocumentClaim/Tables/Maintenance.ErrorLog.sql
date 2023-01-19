USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[ErrorLog]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [DATE]        DateTime              NOT NULL,
        [USER_NAME]   NVarChar(256)         NOT NULL,
        [TYPE]        TinyInt                   NULL,
        [NUM]         Int                       NULL,
        [PROC_NAME]   NVarChar(256)             NULL,
        [MESSAGE]     NVarChar(4096)            NULL,
        CONSTRAINT [PK_Maintenance.ErrorLog] PRIMARY KEY CLUSTERED ([ID])
);
GO
