USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientTypeRules]
(
        [System_Id]       Int          NOT NULL,
        [DistrType_Id]    Int          NOT NULL,
        [ClientType_Id]   TinyInt      NOT NULL,
        CONSTRAINT [PK_dbo.ClientTypeRules] PRIMARY KEY CLUSTERED ([System_Id],[DistrType_Id]),
        CONSTRAINT [FK_dbo.ClientTypeRules(System_Id)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([System_Id]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.ClientTypeRules(DistrType_Id)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([DistrType_Id]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_dbo.ClientTypeRules(ClientType_Id)_dbo.ClientTypeTable(ClientTypeID)] FOREIGN KEY  ([ClientType_Id]) REFERENCES [dbo].[ClientTypeTable] ([ClientTypeID])
);GO
