USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OnlineRules]
(
        [System_Id]      Int           NOT NULL,
        [DistrType_Id]   Int           NOT NULL,
        [Quantity]       SmallInt          NULL,
        CONSTRAINT [PK_dbo.OnlineRules] PRIMARY KEY CLUSTERED ([System_Id],[DistrType_Id]),
        CONSTRAINT [FK_dbo.OnlineRules(System_Id)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([System_Id]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.OnlineRules(DistrType_Id)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([DistrType_Id]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID])
);
GO
