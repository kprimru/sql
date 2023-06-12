USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NDS_01]
(
        [ID]       Int             Identity(1,1)   NOT NULL,
        [CLIENT]   NVarChar(510)                       NULL,
        [TP]       NVarChar(510)                       NULL,
        [PRICE]    Money                               NULL,
        [PRICE2]   Money                               NULL,
        [P1S]      NVarChar(510)                       NULL,
        [P2S]      NVarChar(510)                       NULL,
        CONSTRAINT [PK_dbo.NDS_01] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.NDS_01(TP)+(ID,CLIENT,PRICE,PRICE2)] ON [dbo].[NDS_01] ([TP] ASC) INCLUDE ([ID], [CLIENT], [PRICE], [PRICE2]);
GO
