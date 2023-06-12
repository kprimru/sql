USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Period]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [TYPE]            TinyInt               NOT NULL,
        [NAME]            NVarChar(512)         NOT NULL,
        [START]           SmallDateTime         NOT NULL,
        [FINISH]          SmallDateTime         NOT NULL,
        [ACTIVE]          Bit                   NOT NULL,
        [START_REPORT]    SmallDateTime             NULL,
        [FINISH_REPORT]   SmallDateTime             NULL,
        CONSTRAINT [PK_Common.Period] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.Period(TYPE,ACTIVE,START)+(NAME,FINISH)] ON [Common].[Period] ([TYPE] ASC, [ACTIVE] ASC, [START] ASC) INCLUDE ([NAME], [FINISH]);
CREATE NONCLUSTERED INDEX [IX_Common.Period(TYPE,START,FINISH)] ON [Common].[Period] ([TYPE] ASC, [START] ASC, [FINISH] ASC);
CREATE NONCLUSTERED INDEX [IX_Common.Period(TYPE,START_REPORT,FINISH_REPORT)] ON [Common].[Period] ([TYPE] ASC, [START_REPORT] ASC, [FINISH_REPORT] ASC);
GO
