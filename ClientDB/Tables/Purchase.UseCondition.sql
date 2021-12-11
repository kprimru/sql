USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[UseCondition]
(
        [UC_ID]      UniqueIdentifier      NOT NULL,
        [UC_NAME]    VarChar(Max)          NOT NULL,
        [UC_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.UseCondition] PRIMARY KEY CLUSTERED ([UC_ID])
);
GO
