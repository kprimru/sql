USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[WeightCorrection]
(
        [WC_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [WC_ID_QUARTER]   SmallInt                   NOT NULL,
        [WC_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.WeightCorrection] PRIMARY KEY CLUSTERED ([WC_ID])
);GO
