USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClaimProvision]
(
        [CP_ID]      UniqueIdentifier      NOT NULL,
        [CP_NAME]    VarChar(4000)         NOT NULL,
        [CP_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.ClaimProvision] PRIMARY KEY CLUSTERED ([CP_ID])
);GO
