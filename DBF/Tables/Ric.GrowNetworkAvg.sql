USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[GrowNetworkAvg]
(
        [GNA_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [GNA_ID_QUARTER]   SmallInt                   NOT NULL,
        [GNA_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.GrowNetworkAvg] PRIMARY KEY CLUSTERED ([GNA_ID]),
        CONSTRAINT [FK_Ric.GrowNetworkAvg(GNA_ID_QUARTER)_Ric.Quarter(QR_ID)] FOREIGN KEY  ([GNA_ID_QUARTER]) REFERENCES [dbo].[Quarter] ([QR_ID])
);GO
