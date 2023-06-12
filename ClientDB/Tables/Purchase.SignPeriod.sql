USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[SignPeriod]
(
        [SP_ID]      UniqueIdentifier      NOT NULL,
        [SP_NAME]    VarChar(1000)         NOT NULL,
        [SP_SHORT]   VarChar(100)          NOT NULL,
        CONSTRAINT [PK_Purchase.SignPeriod] PRIMARY KEY CLUSTERED ([SP_ID])
);
GO
