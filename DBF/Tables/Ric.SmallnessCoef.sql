USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[SmallnessCoef]
(
        [SC_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [SC_ID_QUARTER]   SmallInt                   NOT NULL,
        [SC_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.SmallnessCoef] PRIMARY KEY CLUSTERED ([SC_ID]),
        CONSTRAINT [FK_Ric.SmallnessCoef(SC_ID_QUARTER)_Ric.Quarter(QR_ID)] FOREIGN KEY  ([SC_ID_QUARTER]) REFERENCES [dbo].[Quarter] ([QR_ID])
);GO
