USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HotlineDistr]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_HOST]      Int                   NOT NULL,
        [DISTR]        Int                   NOT NULL,
        [COMP]         TinyInt               NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        [SET_DATE]     DateTime              NOT NULL,
        [SET_USER]     NVarChar(256)         NOT NULL,
        [UNSET_DATE]   DateTime                  NULL,
        [UNSET_USER]   NVarChar(256)             NULL,
        CONSTRAINT [PK_dbo.HotlineDistr] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.HotlineDistr(ID_HOST)_dbo.Hosts(HostID)] FOREIGN KEY  ([ID_HOST]) REFERENCES [dbo].[Hosts] ([HostID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.HotlineDistr(DISTR,ID_HOST,COMP,STATUS)+(SET_DATE,SET_USER,UNSET_DATE,UNSET_USER)] ON [dbo].[HotlineDistr] ([DISTR] ASC, [ID_HOST] ASC, [COMP] ASC, [STATUS] ASC) INCLUDE ([SET_DATE], [SET_USER], [UNSET_DATE], [UNSET_USER]);
GO
