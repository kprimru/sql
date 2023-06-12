USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[ProcessorFamily]
(
        [PF_ID]     Int            Identity(1,1)   NOT NULL,
        [PF_NAME]   VarChar(150)                   NOT NULL,
        CONSTRAINT [PK_USR.ProcessorFamily] PRIMARY KEY CLUSTERED ([PF_ID])
);
GO
