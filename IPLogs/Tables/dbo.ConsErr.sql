USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsErr]
(
        [ID]                         bigint      Identity(1,1)   NOT NULL,
        [ID_USR]                     nchar(20)                   NOT NULL,
        [ERROR_DATA_COMPRESSED]      varbinary                       NULL,
        [INET_LOG_DATA_COMPRESSED]   varbinary                       NULL,
        [ERROR_DATA]                  AS (Decompress([ERROR_DATA_COMPRESSED])) ,
        [INET_LOG_DATA]               AS (Decompress([INET_LOG_DATA_COMPRESSED])) ,
        CONSTRAINT [PK_dbo.ConsErr] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ConsErr(ID_USR)] ON [dbo].[ConsErr] ([ID_USR] ASC);
GO
