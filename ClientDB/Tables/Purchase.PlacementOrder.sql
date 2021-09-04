USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[PlacementOrder]
(
        [PO_ID]     UniqueIdentifier      NOT NULL,
        [PO_NAME]   VarChar(150)          NOT NULL,
        [PO_NUM]    SmallInt              NOT NULL,
        CONSTRAINT [PK_Purchase.PlacementOrder] PRIMARY KEY CLUSTERED ([PO_ID])
);GO
