USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NDS_04]
(
        [ID]       Int             Identity(1,1)   NOT NULL,
        [CLIENT]   NVarChar(510)                       NULL,
        [TP]       NVarChar(510)                       NULL,
        [PRICE]    Money                               NULL,
        [PRICE2]   Money                               NULL,
        [P1S]      NVarChar(510)                       NULL,
        [P2S]      NVarChar(510)                       NULL,
        CONSTRAINT [PK_dbo.NDS_04] PRIMARY KEY CLUSTERED ([ID])
);
GO
