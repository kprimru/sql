USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reg].[RegDistr]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_HOST]       Int                   NOT NULL,
        [DISTR]         Int                   NOT NULL,
        [COMP]          TinyInt               NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [CREATE_DATE]   DateTime              NOT NULL,
        CONSTRAINT [PK_Reg.RegDistr] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_Reg.RegDistr(ID_HOST)_dbo.Hosts(HostID)] FOREIGN KEY  ([ID_HOST]) REFERENCES [dbo].[Hosts] ([HostID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Reg.RegDistr(DISTR,ID_HOST,COMP)] ON [Reg].[RegDistr] ([DISTR] ASC, [ID_HOST] ASC, [COMP] ASC);
GO
