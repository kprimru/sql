USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[District]
(
        [DS_ID]        UniqueIdentifier      NOT NULL,
        [DS_NAME]      VarChar(100)          NOT NULL,
        [DS_ID_CITY]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_dbo.District] PRIMARY KEY CLUSTERED ([DS_ID]),
        CONSTRAINT [FK_dbo.District(DS_ID_CITY)_dbo.City(CT_ID)] FOREIGN KEY  ([DS_ID_CITY]) REFERENCES [dbo].[City] ([CT_ID])
);
GO
