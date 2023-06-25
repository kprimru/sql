USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[File]
(
        [Id]               Int            Identity(1,1)   NOT NULL,
        [Type_Id]          SmallInt                       NOT NULL,
        [UploadDateTime]   DateTime                       NOT NULL,
        [UploadUser]       VarChar(128)                   NOT NULL,
        [Data]             varbinary                          NULL,
        CONSTRAINT [PK__File__3214EC07FB83A603] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK__File__Type_Id__7C30464A] FOREIGN KEY  ([Type_Id]) REFERENCES [Import].[File->Type] ([Id])
);
GO
