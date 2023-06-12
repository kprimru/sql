USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActCalc]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [DATE]           DateTime              NOT NULL,
        [USR]            VarChar(128)          NOT NULL,
        [SERVICE]        VarChar(128)          NOT NULL,
        [CONFIRM_NEED]   Bit                       NULL,
        [CONFIRM_USER]   NVarChar(256)             NULL,
        [CONFIRM_DATE]   DateTime                  NULL,
        [STATUS]         TinyInt               NOT NULL,
        [CALC_STATUS]    NVarChar(256)             NULL,
        CONSTRAINT [PK_dbo.ActCalc] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ActCalc(STATUS)+(ID,CALC_STATUS,DATE)] ON [dbo].[ActCalc] ([STATUS] ASC) INCLUDE ([ID], [CALC_STATUS], [DATE]);
GO
