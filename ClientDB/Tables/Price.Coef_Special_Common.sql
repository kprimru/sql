USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[Coef:Special:Common]
(
        [System_Id]      Int                NOT NULL,
        [DistrType_Id]   Int                NOT NULL,
        [Date]           SmallDateTime      NOT NULL,
        [Coef]           decimal                NULL,
        [Round]          SmallInt           NOT NULL,
        CONSTRAINT [PK_Price.Coef:Special:Common] PRIMARY KEY NONCLUSTERED ([System_Id],[DistrType_Id],[Date]),
        CONSTRAINT [FK_Price.Coef:Special:Common(DistrType_Id)_Price.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([DistrType_Id]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_Price.Coef:Special:Common(System_Id)_Price.SystemTable(SystemID)] FOREIGN KEY  ([System_Id]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
