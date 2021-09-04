USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceReport]
(
        [SR_ID]        UniqueIdentifier      NOT NULL,
        [SR_SERVICE]   VarChar(100)              NULL,
        [SR_MANAGER]   VarChar(100)              NULL,
        [SR_CSTATUS]   VarChar(Max)          NOT NULL,
        [SR_SSTATUS]   VarChar(Max)          NOT NULL,
        [SR_DATE]      SmallDateTime         NOT NULL,
        [SR_CREATE]    DateTime              NOT NULL,
        [SR_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ServiceReport] PRIMARY KEY CLUSTERED ([SR_ID])
);GO
