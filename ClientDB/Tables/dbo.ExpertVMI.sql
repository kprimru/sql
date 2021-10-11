USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpertVMI]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [MON]     SmallDateTime         NOT NULL,
        [DISTR]   NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.ExpertVMI] PRIMARY KEY CLUSTERED ([ID])
);GO
