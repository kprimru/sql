USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrTypeCoef]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [ID_NET]     Int                   NOT NULL,
        [ID_MONTH]   UniqueIdentifier      NOT NULL,
        [COEF]       decimal               NOT NULL,
        [WEIGHT]     decimal                   NULL,
        [RND]        SmallInt              NOT NULL,
        CONSTRAINT [PK_dbo.DistrTypeCoef] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.DistrTypeCoef(ID_NET)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([ID_NET]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_dbo.DistrTypeCoef(ID_MONTH)_dbo.Period(ID)] FOREIGN KEY  ([ID_MONTH]) REFERENCES [Common].[Period] ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.DistrTypeCoef(ID_NET,ID_MONTH)] ON [dbo].[DistrTypeCoef] ([ID_NET] ASC, [ID_MONTH] ASC);
GO
