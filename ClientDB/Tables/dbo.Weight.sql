USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Weight]
(
        [Date]            SmallDateTime      NOT NULL,
        [System_Id]       Int                NOT NULL,
        [SystemType_Id]   Int                NOT NULL,
        [NetType_Id]      Int                NOT NULL,
        [Weight]          decimal            NOT NULL,
        CONSTRAINT [PK_dbo.Weight] PRIMARY KEY CLUSTERED ([Date],[System_Id],[SystemType_Id],[NetType_Id]),
        CONSTRAINT [FK_dbo.Weight(NetType_Id)_Din.NetType(NT_ID)] FOREIGN KEY  ([NetType_Id]) REFERENCES [Din].[NetType] ([NT_ID]),
        CONSTRAINT [FK_dbo.Weight(System_Id)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([System_Id]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.Weight(SystemType_Id)_Din.SystemType(SST_ID)] FOREIGN KEY  ([SystemType_Id]) REFERENCES [Din].[SystemType] ([SST_ID])
);
GO
