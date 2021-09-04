USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceGroupTable]
(
        [PG_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [PG_NAME]     VarChar(50)                   NOT NULL,
        [PG_ORDER]    Int                               NULL,
        [PG_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.PriceGroupTable] PRIMARY KEY CLUSTERED ([PG_ID])
);GO
