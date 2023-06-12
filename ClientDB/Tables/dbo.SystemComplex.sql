USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemComplex]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   Int                   NOT NULL,
        [ID_SLAVE]    Int                   NOT NULL,
        CONSTRAINT [PK_dbo.SystemComplex] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.SystemComplex(ID_MASTER)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.SystemComplex(ID_SLAVE)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SLAVE]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.SystemComplex(ID_MASTER,ID_SLAVE)] ON [dbo].[SystemComplex] ([ID_MASTER] ASC, [ID_SLAVE] ASC);
GO
