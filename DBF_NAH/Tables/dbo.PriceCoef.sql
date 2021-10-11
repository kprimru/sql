USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceCoef]
(
        [PC_ID]          Int        Identity(1,1)   NOT NULL,
        [PC_ID_SYSTEM]   SmallInt                   NOT NULL,
        [PC_ID_PERIOD]   SmallInt                   NOT NULL,
        [PC_COEF]        decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.PriceCoef] PRIMARY KEY CLUSTERED ([PC_ID])
);GO
