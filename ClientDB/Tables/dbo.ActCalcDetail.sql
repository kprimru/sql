USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActCalcDetail]
(
        [ID_MASTER]   UniqueIdentifier      NOT NULL,
        [SYS_REG]     NVarChar(128)         NOT NULL,
        [DISTR]       Int                   NOT NULL,
        [COMP]        TinyInt               NOT NULL,
        [MON]         SmallDateTime         NOT NULL,
        [CONFRM]      Bit                       NULL,
        [CALC_NOTE]   NVarChar(512)             NULL,
        [CALC_DATE]   DateTime                  NULL,
        CONSTRAINT [PK_ActCalcDetail] PRIMARY KEY CLUSTERED ([ID_MASTER],[SYS_REG],[DISTR],[COMP],[MON]),
        CONSTRAINT [FK_dbo.ActCalcDetail(ID_MASTER)_dbo.ActCalc(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ActCalc] ([ID])
);
GO
