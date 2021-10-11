USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Servers]
(
        [SRV_ID]       Int              Identity(1,1)   NOT NULL,
        [SRV_NAME]     VarChar(50)                      NOT NULL,
        [SRV_PATH]     NVarChar(1024)                   NOT NULL,
        [SRV_REPORT]   NVarChar(1024)                   NOT NULL,
        CONSTRAINT [PK_dbo.Servers] PRIMARY KEY CLUSTERED ([SRV_ID])
);GO
