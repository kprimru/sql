USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[KBU]
(
        [RK_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [RK_ID_QUARTER]   SmallInt                   NOT NULL,
        [RK_KBU]          decimal                    NOT NULL,
        [RK_STOCK]        decimal                    NOT NULL,
        [RK_TOTAL]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.KBU] PRIMARY KEY CLUSTERED ([RK_ID]),
        CONSTRAINT [FK_Ric.KBU(RK_ID_QUARTER)_Ric.Quarter(QR_ID)] FOREIGN KEY  ([RK_ID_QUARTER]) REFERENCES [dbo].[Quarter] ([QR_ID])
);GO
