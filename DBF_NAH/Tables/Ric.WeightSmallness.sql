USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[WeightSmallness]
(
        [WS_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [WS_ID_QUARTER]   SmallInt                   NOT NULL,
        [WS_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.WeightSmallness] PRIMARY KEY CLUSTERED ([WS_ID])
);
GO
