USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[File:Item]
(
        [Id]           Int   Identity(1,1)   NOT NULL,
        [File_Id]      Int                   NOT NULL,
        [Data]         xml                       NULL,
        [UploadData]   xml                       NULL,
        [Row_Id]       Int                   NOT NULL,
        CONSTRAINT [PK__File:Ite__3214EC074D8E9A28] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK__File:Item__File___7F0CB2F5] FOREIGN KEY  ([File_Id]) REFERENCES [Import].[File] ([Id])
);
GO
