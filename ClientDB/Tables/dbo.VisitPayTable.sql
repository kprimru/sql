USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VisitPayTable]
(
        [VisitPayID]      Int             Identity(1,1)   NOT NULL,
        [VisitPayValue]   Money                           NOT NULL,
        [VisitPayBegin]   SmallDateTime                       NULL,
        [VisitPayEnd]     SmallDateTime                       NULL,
        CONSTRAINT [PK_dbo.VisitPayTable] PRIMARY KEY CLUSTERED ([VisitPayID])
);GO
