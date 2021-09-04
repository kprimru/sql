USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsErr]
(
        [ID]              bigint          Identity(1,1)   NOT NULL,
        [ID_USR]          nchar(20)                       NOT NULL,
        [ERROR_DATA]      NVarChar(Max)                       NULL,
        [INET_LOG_DATA]   NVarChar(Max)                       NULL,
        CONSTRAINT [PK_dbo.ConsErr] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ConsErr(ID_USR)] ON [dbo].[ConsErr] ([ID_USR] ASC);
GO
