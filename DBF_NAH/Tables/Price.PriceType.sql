USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[PriceType]
(
        [PT_ID]       SmallInt       Identity(1,1)   NOT NULL,
        [PT_NAME]     VarChar(100)                   NOT NULL,
        [PT_SHORT]    VarChar(50)                    NOT NULL,
        [PT_PSEDO]    VarChar(50)                    NOT NULL,
        [PT_GROUP]    VarChar(50)                    NOT NULL,
        [PT_ORDER]    Int                            NOT NULL,
        [PT_ACTIVE]   Bit                            NOT NULL,
        CONSTRAINT [PK_Price.PriceType] PRIMARY KEY CLUSTERED ([PT_ID])
);
GO
