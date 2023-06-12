USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[Groups_Params]
(
        [Id]          TinyInt        Identity(1,1)   NOT NULL,
        [Group_Id]    TinyInt                        NOT NULL,
        [Code]        VarChar(100)                   NOT NULL,
        [Name]        VarChar(100)                   NOT NULL,
        [SortIndex]   TinyInt                        NOT NULL,
        [FieldName]   VarChar(100)                   NOT NULL,
        [ErrorCode]   VarChar(20)                        NULL,,
        CONSTRAINT [FK_Groups_Params_Groups] FOREIGN KEY  ([Group_Id]) REFERENCES [USR].[Groups] ([Id])
);
GO
