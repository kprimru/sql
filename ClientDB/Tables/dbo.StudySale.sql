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
        [FIO]               VarChar(256)          NOT NULL,
        [RIVAL_CLIENT_ID]   Int                       NULL,
        [RIVAL_CLIENT]      VarChar(50)               NULL,
        [LPR]               VarChar(256)              NULL,
        [USER_POST]         VarChar(Max)              NULL,
        [NOTE]              VarChar(Max)              NULL,
        [Lprs]              VarChar(Max)              NULL,
        [Workers]           VarChar(Max)              NULL,
        CONSTRAINT [PK_dbo.StudySale] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.StudySale(ID_CLIENT)] ON [dbo].[StudySale] ([ID_CLIENT] ASC);
GO
