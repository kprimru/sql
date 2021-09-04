USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ControlDocument]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [DATE]       DateTime              NOT NULL,
        [DATE_S]      AS ([dbo].[DateOf]([DATE])) PERSISTED,
        [RIC]        SmallInt              NOT NULL,
        [SYS_NUM]    Int                   NOT NULL,
        [DISTR]      Int                   NOT NULL,
        [COMP]       TinyInt               NOT NULL,
        [IB]         VarChar(50)           NOT NULL,
        [IB_NUM]     Int                       NULL,
        [DOC_NAME]   VarChar(1024)         NOT NULL,
        CONSTRAINT [PK_dbo.ControlDocument] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ControlDocument(DATE_S)+(SYS_NUM,DISTR,COMP,IB,IB_NUM)] ON [dbo].[ControlDocument] ([DATE_S] ASC) INCLUDE ([SYS_NUM], [DISTR], [COMP], [IB], [IB_NUM]);
CREATE NONCLUSTERED INDEX [IX_dbo.ControlDocument(DISTR,COMP,SYS_NUM)+(DATE,RIC,IB,IB_NUM,DOC_NAME)] ON [dbo].[ControlDocument] ([DISTR] ASC, [COMP] ASC, [SYS_NUM] ASC) INCLUDE ([DATE], [RIC], [IB], [IB_NUM], [DOC_NAME]);
GO
