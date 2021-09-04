USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhoneType]
(
        [PT_ID]      UniqueIdentifier      NOT NULL,
        [PT_NAME]    VarChar(50)           NOT NULL,
        [PT_SHORT]   VarChar(20)           NOT NULL,
        CONSTRAINT [PK_dbo.PhoneType] PRIMARY KEY CLUSTERED ([PT_ID])
);GO
