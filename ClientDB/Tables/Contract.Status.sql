USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Status]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        [IND]    SmallInt              NOT NULL,
        [ORD]    SmallInt              NOT NULL,
        CONSTRAINT [PK_Contract.Status] PRIMARY KEY CLUSTERED ([ID])
);
GO
