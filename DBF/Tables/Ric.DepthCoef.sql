USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[DepthCoef]
(
        [DC_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [DC_ID_QUARTER]   SmallInt                   NOT NULL,
        [DC_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.DepthCoef] PRIMARY KEY CLUSTERED ([DC_ID]),
        CONSTRAINT [FK_Ric.DepthCoef(DC_ID_QUARTER)_Ric.Quarter(QR_ID)] FOREIGN KEY  ([DC_ID_QUARTER]) REFERENCES [dbo].[Quarter] ([QR_ID])
);
GO
