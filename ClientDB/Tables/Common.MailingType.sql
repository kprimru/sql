USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MailingType]
(
        [MailingTypeId]     TinyInt        Identity(1,1)   NOT NULL,
        [MailingTypeName]   NVarChar(60)                   NOT NULL,
        [MailingTypeCode]   VarChar(50)                        NULL,
        CONSTRAINT [PK_Common.MailingType] PRIMARY KEY CLUSTERED ([MailingTypeId])
);
GO
