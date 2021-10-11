USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiscountTable]
(
        [DiscountID]      Int           Identity(1,1)   NOT NULL,
        [DiscountValue]   VarChar(50)                   NOT NULL,
        [DiscountOrder]   Int                           NOT NULL,
        CONSTRAINT [PK_dbo.DiscountTable] PRIMARY KEY CLUSTERED ([DiscountID])
);GO
