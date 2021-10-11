USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NDS1CDetail]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier      NOT NULL,
        [CLIENT]      NVarChar(512)         NOT NULL,
        [TP]          NVarChar(128)             NULL,
        [PRICE]       Money                     NULL,
        [PRICE2]      Money                     NULL,
        CONSTRAINT [PK_dbo.NDS1CDetail] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.NDS1CDetail(ID_MASTER)_dbo.NDS1C(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[NDS1C] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.NDS1CDetail(ID_MASTER)+(CLIENT,TP,PRICE,PRICE2)] ON [dbo].[NDS1CDetail] ([ID_MASTER] ASC) INCLUDE ([CLIENT], [TP], [PRICE], [PRICE2]);
CREATE NONCLUSTERED INDEX [IX_dbo.NDS1CDetail(ID_MASTER,TP)+(CLIENT,PRICE2,PRICE)] ON [dbo].[NDS1CDetail] ([ID_MASTER] ASC, [TP] ASC) INCLUDE ([CLIENT], [PRICE2], [PRICE]);
GO
