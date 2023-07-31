USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[Coef:Special]
(
        [System_Id]       Int                NOT NULL,
        [DistrType_Id]    Int                NOT NULL,
        [SystemType_Id]   Int                NOT NULL,
        [Date]            SmallDateTime      NOT NULL,
        [Coef]            decimal                NULL,
        [Round]           SmallInt           NOT NULL,
        CONSTRAINT [PK_Price.Coef:Special] PRIMARY KEY NONCLUSTERED ([System_Id],[DistrType_Id],[SystemType_Id],[Date]),
        CONSTRAINT [FK_Price.Coef:Special(DistrType_Id)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([DistrType_Id]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_Price.Coef:Special(SystemType_Id)_dbo.SystemTypeTable(SystemTypeID)] FOREIGN KEY  ([SystemType_Id]) REFERENCES [dbo].[SystemTypeTable] ([SystemTypeID]),
        CONSTRAINT [FK_Price.Coef:Special(System_Id)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([System_Id]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
