USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[System:Price]
(
        [System_Id]   Int                NOT NULL,
        [Date]        SmallDateTime      NOT NULL,
        [Price]       Money              NOT NULL,
        [UPD_USER]    NVarChar(256)      NOT NULL,
        [UPD_DATE]    DateTime           NOT NULL,
        CONSTRAINT [PK_Price.System:Price] PRIMARY KEY CLUSTERED ([System_Id],[Date]),
        CONSTRAINT [FK_Price.System:Price(System_Id)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([System_Id]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
