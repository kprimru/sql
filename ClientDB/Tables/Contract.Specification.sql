USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Specification]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [NUM]         NVarChar(256)         NOT NULL,
        [NAME]        NVarChar(512)         NOT NULL,
        [NOTE]        NVarChar(Max)             NULL,
        [FILE_PATH]   NVarChar(1024)            NULL,
        CONSTRAINT [PK_Contract.Specification] PRIMARY KEY CLUSTERED ([ID])
);
GO
