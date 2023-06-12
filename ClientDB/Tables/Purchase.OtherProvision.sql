USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[OtherProvision]
(
        [OP_ID]      UniqueIdentifier      NOT NULL,
        [OP_NAME]    VarChar(4000)         NOT NULL,
        [OP_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.OtherProvision] PRIMARY KEY CLUSTERED ([OP_ID])
);
GO
