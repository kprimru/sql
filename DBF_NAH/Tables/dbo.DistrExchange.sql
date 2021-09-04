USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrExchange]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [OLD_HOST]   Int                   NOT NULL,
        [OLD_NUM]    Int                   NOT NULL,
        [OLD_COMP]   TinyInt               NOT NULL,
        [NEW_HOST]   Int                   NOT NULL,
        [NEW_NUM]    Int                   NOT NULL,
        [NEW_COMP]   TinyInt               NOT NULL,
        CONSTRAINT [PK_dbo.DistrExchange] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.DistrExchange(NEW_NUM,NEW_HOST,NEW_COMP)+(OLD_HOST,OLD_NUM,OLD_COMP)] ON [dbo].[DistrExchange] ([NEW_NUM] ASC, [NEW_HOST] ASC, [NEW_COMP] ASC) INCLUDE ([OLD_HOST], [OLD_NUM], [OLD_COMP]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.DistrExchange(OLD_NUM,OLD_HOST,OLD_COMP)+(NEW_HOST,NEW_NUM,NEW_COMP)] ON [dbo].[DistrExchange] ([OLD_NUM] ASC, [OLD_HOST] ASC, [OLD_COMP] ASC) INCLUDE ([NEW_HOST], [NEW_NUM], [NEW_COMP]);
GO
