USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[Processor]
(
        [PRC_ID]          Int            Identity(1,1)   NOT NULL,
        [PRC_NAME]        VarChar(100)                   NOT NULL,
        [PRC_FREQ_S]      VarChar(50)                    NOT NULL,
        [PRC_FREQ]        decimal                        NOT NULL,
        [PRC_CORE]        SmallInt                       NOT NULL,
        [PRC_ID_FAMILY]   Int                                NULL,
        CONSTRAINT [PK_USR.Processor] PRIMARY KEY CLUSTERED ([PRC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_USR.Processor(PRC_NAME,PRC_FREQ_S,PRC_CORE)+(PRC_ID)] ON [USR].[Processor] ([PRC_NAME] ASC, [PRC_FREQ_S] ASC, [PRC_CORE] ASC) INCLUDE ([PRC_ID]);
GO
