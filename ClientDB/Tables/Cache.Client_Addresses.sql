USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cache].[Client?Addresses]
(
        [Id]                Int                   NOT NULL,
        [Type_Id]           UniqueIdentifier      NOT NULL,
        [DisplayText]       VarChar(Max)              NULL,
        [DisplayTextFull]   VarChar(512)              NULL,
        CONSTRAINT [PK_Cache.Client?Addresses] PRIMARY KEY CLUSTERED ([Id],[Type_Id])
);
GO
