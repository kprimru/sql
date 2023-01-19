USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsErr]
(
        [ID_USR]                     Int            NOT NULL,
        [ERROR_DATA_COMPRESSED]      varbinary          NULL,
        [INET_LOG_DATA_COMPRESSED]   varbinary          NULL,
        [ERROR_DATA]                  AS (Decompress([ERROR_DATA_COMPRESSED])) ,
        [INET_LOG_DATA]               AS (Decompress([INET_LOG_DATA_COMPRESSED])) ,
        CONSTRAINT [PK_dbo.ConsErr] PRIMARY KEY CLUSTERED ([ID_USR]),
        CONSTRAINT [FK_dbo.ConsErr(ID_USR)_dbo.USRFiles(UF_ID)] FOREIGN KEY  ([ID_USR]) REFERENCES [dbo].[USRFiles] ([UF_ID])
);
GO
