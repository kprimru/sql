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
        CONSTRAINT [FK_Client_Type_Rules_System_Id] FOREIGN KEY  ([System_Id]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_Client_Type_Rules_DistrType_Id] FOREIGN KEY  ([DistrType_Id]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_Client_Type_Rules_ClientType_Id] FOREIGN KEY  ([ClientType_Id]) REFERENCES [dbo].[ClientTypeTable] ([ClientTypeID])
);GO
