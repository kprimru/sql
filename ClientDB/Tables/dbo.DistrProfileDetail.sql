USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrProfileDetail]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier      NOT NULL,
        [ID_PROFILE]   UniqueIdentifier      NOT NULL,
        [CNT]          SmallInt              NOT NULL,
        CONSTRAINT [PK_dbo.DistrProfileDetail] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.DistrProfileDetail(ID_MASTER)_dbo.DistrProfile(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[DistrProfile] ([ID]),
        CONSTRAINT [FK_dbo.DistrProfileDetail(ID_PROFILE)_dbo.ProfileType(ID)] FOREIGN KEY  ([ID_PROFILE]) REFERENCES [dbo].[ProfileType] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.DistrProfileDetail(ID_MASTER)+(ID_PROFILE,CNT)] ON [dbo].[DistrProfileDetail] ([ID_MASTER] ASC) INCLUDE ([ID_PROFILE], [CNT]);
GO
