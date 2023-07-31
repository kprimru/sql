USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostEmail]
(
        [Subhost_Id]   UniqueIdentifier      NOT NULL,
        [Type_Id]      TinyInt               NOT NULL,
        [Email]        VarChar(512)              NULL,
        CONSTRAINT [PK_dbo.SubhostEmail] PRIMARY KEY CLUSTERED ([Subhost_Id],[Type_Id])
);
GO
