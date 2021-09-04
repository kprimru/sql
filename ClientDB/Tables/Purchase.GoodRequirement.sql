USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[GoodRequirement]
(
        [GR_ID]      UniqueIdentifier      NOT NULL,
        [GR_NAME]    VarChar(4000)         NOT NULL,
        [GR_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.GoodRequirement] PRIMARY KEY CLUSTERED ([GR_ID])
);GO
