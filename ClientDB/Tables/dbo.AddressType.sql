USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddressType]
(
        [AT_ID]         UniqueIdentifier      NOT NULL,
        [AT_NAME]       VarChar(100)          NOT NULL,
        [AT_REQUIRED]   Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.AddressType] PRIMARY KEY CLUSTERED ([AT_ID])
);
GO
