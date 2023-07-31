USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[DistrType:Coef]
(
        [DistrType_Id]   Int                NOT NULL,
        [Date]           SmallDateTime      NOT NULL,
        [Coef]           decimal                NULL,
        [Round]          SmallInt           NOT NULL,
        CONSTRAINT [PK_Price.DistrType:Coef] PRIMARY KEY CLUSTERED ([DistrType_Id],[Date]),
        CONSTRAINT [FK_Price.DistrType:Coef(DistrType_Id)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([DistrType_Id]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID])
);
GO
