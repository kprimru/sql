USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[WeightCorrectionMonth]
(
        [WC_ID]          SmallInt   Identity(1,1)   NOT NULL,
        [WC_ID_PERIOD]   SmallInt                   NOT NULL,
        [WC_VALUE]       decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.WeightCorrectionMonth] PRIMARY KEY CLUSTERED ([WC_ID])
);
GO
