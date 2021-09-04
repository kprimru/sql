USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceCity]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_SERVICE]   Int                   NOT NULL,
        [ID_CITY]      UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_dbo.ServiceCity] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ServiceCity(ID_SERVICE)_dbo.ServiceTable(ServiceID)] FOREIGN KEY  ([ID_SERVICE]) REFERENCES [dbo].[ServiceTable] ([ServiceID]),
        CONSTRAINT [FK_dbo.ServiceCity(ID_CITY)_dbo.City(CT_ID)] FOREIGN KEY  ([ID_CITY]) REFERENCES [dbo].[City] ([CT_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ServiceCity(ID_SERVICE,ID_CITY)] ON [dbo].[ServiceCity] ([ID_SERVICE] ASC, [ID_CITY] ASC);
GO
