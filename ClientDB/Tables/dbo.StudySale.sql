USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudySale]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [ID_CLIENT]         Int                   NOT NULL,
        [DATE]              SmallDateTime         NOT NULL,
        [FIO]               NVarChar(512)         NOT NULL,
        [RIVAL_CLIENT_ID]   Int                       NULL,
        [RIVAL_CLIENT]      NVarChar(100)             NULL,
        [LPR]               NVarChar(512)             NULL,
        [USER_POST]         NVarChar(200)             NULL,
        [NOTE]              NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.StudySale] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.StudySale(ID_CLIENT)] ON [dbo].[StudySale] ([ID_CLIENT] ASC);
GO
