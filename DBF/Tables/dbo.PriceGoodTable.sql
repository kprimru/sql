USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceGoodTable]
(
        [PGD_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [PGD_NAME]     VarChar(50)                   NOT NULL,
        [PGD_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.PriceGoodTable] PRIMARY KEY CLUSTERED ([PGD_ID])
);
GO
