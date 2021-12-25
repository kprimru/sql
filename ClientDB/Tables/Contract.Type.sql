USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Type]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [NAME]         NVarChar(256)         NOT NULL,
        [CDAY]         SmallInt              NOT NULL,
        [CMONTH]       SmallInt              NOT NULL,
        [PREFIX]       NVarChar(64)          NOT NULL,
        [FORM]         NVarChar(64)          NOT NULL,
        [Type_Id]      Int                       NULL,
        [PayType_Id]   Int                       NULL,
        CONSTRAINT [PK_Contract.Type] PRIMARY KEY CLUSTERED ([ID])
);
GO
