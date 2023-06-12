USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ComplectInfoBankCache]
(
        [ID]             Int           Identity(1,1)   NOT NULL,
        [Complect]       VarChar(20)                   NOT NULL,
        [InfoBankID]     Int                           NOT NULL,
        [InfoBankName]   VarChar(30)                   NOT NULL,
        CONSTRAINT [PK_dbo.ComplectInfoBankCache] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ComplectInfoBankCache(Complect,InfoBankID)] ON [dbo].[ComplectInfoBankCache] ([Complect] ASC, [InfoBankID] ASC);
GO
