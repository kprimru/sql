USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServicePositionTable]
(
        [ServicePositionID]     Int           Identity(1,1)   NOT NULL,
        [ServicePositionName]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.ServicePositionTable] PRIMARY KEY CLUSTERED ([ServicePositionID])
);
GO
