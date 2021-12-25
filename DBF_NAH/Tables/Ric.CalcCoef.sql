USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[CalcCoef]
(
        [CC_ID]              Int        Identity(1,1)   NOT NULL,
        [CC_ID_PERIOD]       SmallInt                   NOT NULL,
        [CC_PRICE]           decimal                        NULL,
        [CC_INCREASE_DISC]   decimal                        NULL,
        [CC_PREPAY_RATE]     decimal                        NULL,
        [CC_PREPAY]          Money                          NULL,
        [CC_PREPAY_DISC]     decimal                        NULL,
        CONSTRAINT [PK_Ric.CalcCoef] PRIMARY KEY CLUSTERED ([CC_ID])
);GO
