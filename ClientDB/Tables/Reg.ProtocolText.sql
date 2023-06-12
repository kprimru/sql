USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reg].[ProtocolText]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [ID_HOST]   Int                   NOT NULL,
        [DATE]      SmallDateTime         NOT NULL,
        [DISTR]     Int                   NOT NULL,
        [COMP]      TinyInt               NOT NULL,
        [CNT]       Int                   NOT NULL,
        [COMMENT]   VarChar(500)          NOT NULL,
        CONSTRAINT [PK_Reg.ProtocolText] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Reg.ProtocolText(DISTR,ID_HOST,COMP)+(DATE,COMMENT)] ON [Reg].[ProtocolText] ([DISTR] ASC, [ID_HOST] ASC, [COMP] ASC) INCLUDE ([DATE], [COMMENT]);
GO
