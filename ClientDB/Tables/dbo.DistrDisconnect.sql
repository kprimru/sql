USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrDisconnect]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [ID_DISTR]   UniqueIdentifier      NOT NULL,
        [NOTE]       NVarChar(Max)         NOT NULL,
        [STATUS]     TinyInt               NOT NULL,
        [UPD_DATE]   DateTime              NOT NULL,
        [UPD_USER]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.DistrDisconnect] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.DistrDisconnect(ID_DISTR)_dbo.ClientDistr(ID)] FOREIGN KEY  ([ID_DISTR]) REFERENCES [dbo].[ClientDistr] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.DistrDisconnect(ID_DISTR,STATUS)+(NOTE)] ON [dbo].[DistrDisconnect] ([ID_DISTR] ASC, [STATUS] ASC) INCLUDE ([NOTE]);
GO
