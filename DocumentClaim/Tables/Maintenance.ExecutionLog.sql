USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[ExecutionLog]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [PROC_SCHEMA]   NVarChar(256)         NOT NULL,
        [PROC_NAME]     NVarChar(256)         NOT NULL,
        [DIRECTION]     NVarChar(64)          NOT NULL,
        [EXEC_DATE]     DateTime              NOT NULL,
        [EXEC_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Maintenance.ExecutionLog] PRIMARY KEY CLUSTERED ([ID])
);
GO
