USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[GrowStandard]
(
        [GS_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [GS_ID_QUARTER]   SmallInt                   NOT NULL,
        [GS_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.GrowStandard] PRIMARY KEY CLUSTERED ([GS_ID]),
        CONSTRAINT [FK_Ric.GrowStandard(GS_ID_QUARTER)_Ric.Quarter(QR_ID)] FOREIGN KEY  ([GS_ID_QUARTER]) REFERENCES [dbo].[Quarter] ([QR_ID])
);
GO
