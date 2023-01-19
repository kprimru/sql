USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourierTypeTable]
(
        [COT_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [COT_NAME]     VarChar(50)                   NOT NULL,
        [COT_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.CourierTypeTable] PRIMARY KEY CLUSTERED ([COT_ID])
);
GO
