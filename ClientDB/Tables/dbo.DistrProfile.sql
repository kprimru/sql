USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrProfile]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_PERIOD]     UniqueIdentifier      NOT NULL,
        [SYS_NAME]      NVarChar(64)          NOT NULL,
        [NET]           NVarChar(128)         NOT NULL,
        [DISTR]         Int                   NOT NULL,
        [COMP]          TinyInt               NOT NULL,
        [USR_COUNT]     SmallInt              NOT NULL,
        [ERR_COUNT]     SmallInt              NOT NULL,
        [PROBLEM_PRC]   decimal               NOT NULL,
        CONSTRAINT [PK_dbo.DistrProfile] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.DistrProfile(ID_PERIOD)_dbo.Period(ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [Common].[Period] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.DistrProfile(DISTR,SYS_NAME,COMP)+(ID_PERIOD,NET,USR_COUNT,ERR_COUNT,PROBLEM_PRC,ID)] ON [dbo].[DistrProfile] ([DISTR] ASC, [SYS_NAME] ASC, [COMP] ASC) INCLUDE ([ID_PERIOD], [NET], [USR_COUNT], [ERR_COUNT], [PROBLEM_PRC], [ID]);
GO
