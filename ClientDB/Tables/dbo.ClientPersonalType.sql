USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientPersonalType]
(
        [CPT_ID]         UniqueIdentifier      NOT NULL,
        [CPT_NAME]       VarChar(100)          NOT NULL,
        [CPT_PSEDO]      VarChar(50)               NULL,
        [CPT_REQUIRED]   Bit                   NOT NULL,
        [CPT_ORDER]      Int                       NULL,
        [CPT_SHORT]      VarChar(20)               NULL,
        CONSTRAINT [PK_dbo.ClientPersonalType] PRIMARY KEY CLUSTERED ([CPT_ID])
);
GO
