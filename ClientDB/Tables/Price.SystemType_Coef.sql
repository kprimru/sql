USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[SystemType:Coef]
(
        [SystemType_Id]   Int                NOT NULL,
        [Date]            SmallDateTime      NOT NULL,
        [Coef]            decimal            NOT NULL,
        [Round]           SmallInt           NOT NULL,
        CONSTRAINT [PK_Price.SystemType:Coef] PRIMARY KEY CLUSTERED ([SystemType_Id],[Date]),
        CONSTRAINT [FK_Price.SystemType:Coef(SystemType_Id)_dbo.SystemTypeTable(SystemTypeID)] FOREIGN KEY  ([SystemType_Id]) REFERENCES [dbo].[SystemTypeTable] ([SystemTypeID])
);
GO
