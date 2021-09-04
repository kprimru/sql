USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemProblem]
(
        [SP_ID]          Int        Identity(1,1)   NOT NULL,
        [SP_ID_SYSTEM]   SmallInt                   NOT NULL,
        [SP_ID_PERIOD]   SmallInt                   NOT NULL,
        [SP_ID_IN]       SmallInt                       NULL,
        [SP_ID_OUT]      SmallInt                       NULL,
        CONSTRAINT [PK_dbo.SystemProblem] PRIMARY KEY CLUSTERED ([SP_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.SystemProblem(SP_ID_SYSTEM,SP_ID_PERIOD)+(SP_ID_IN,SP_ID_OUT)] ON [dbo].[SystemProblem] ([SP_ID_SYSTEM] ASC, [SP_ID_PERIOD] ASC) INCLUDE ([SP_ID_IN], [SP_ID_OUT]);
GO
