USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TOPersonalTable]
(
        [TP_ID]          Int            Identity(1,1)   NOT NULL,
        [TP_ID_TO]       Int                            NOT NULL,
        [TP_ID_RP]       TinyInt                        NOT NULL,
        [TP_ID_POS]      SmallInt                           NULL,
        [TP_SURNAME]     VarChar(100)                   NOT NULL,
        [TP_NAME]        VarChar(100)                   NOT NULL,
        [TP_OTCH]        VarChar(100)                   NOT NULL,
        [TP_PHONE]       VarChar(100)                   NOT NULL,
        [TP_PHONE_OLD]   VarChar(100)                       NULL,
        [TP_LAST]        DateTime                           NULL,
        CONSTRAINT [PK_dbo.TOPersonalTable] PRIMARY KEY NONCLUSTERED ([TP_ID]),
        CONSTRAINT [FK_dbo.TOPersonalTable(TP_ID_RP)_dbo.ReportPositionTable(RP_ID)] FOREIGN KEY  ([TP_ID_RP]) REFERENCES [dbo].[ReportPositionTable] ([RP_ID]),
        CONSTRAINT [FK_dbo.TOPersonalTable(TP_ID_POS)_dbo.PositionTable(POS_ID)] FOREIGN KEY  ([TP_ID_POS]) REFERENCES [dbo].[PositionTable] ([POS_ID]),
        CONSTRAINT [FK_dbo.TOPersonalTable(TP_ID_TO)_dbo.TOTable(TO_ID)] FOREIGN KEY  ([TP_ID_TO]) REFERENCES [dbo].[TOTable] ([TO_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.TOPersonalTable(TP_ID_TO,TP_ID_RP)] ON [dbo].[TOPersonalTable] ([TP_ID_TO] ASC, [TP_ID_RP] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.TOPersonalTable(TP_ID_RP)+(TP_ID_TO,TP_ID_POS)] ON [dbo].[TOPersonalTable] ([TP_ID_RP] ASC) INCLUDE ([TP_ID_TO], [TP_ID_POS]);
CREATE NONCLUSTERED INDEX [IX_dbo.TOPersonalTable(TP_PHONE)+(TP_ID_TO,TP_ID)] ON [dbo].[TOPersonalTable] ([TP_PHONE] ASC) INCLUDE ([TP_ID_TO], [TP_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.TOPersonalTable(TP_SURNAME,TP_NAME,TP_OTCH)+(TP_ID,TP_ID_TO,TP_ID_RP,TP_ID_POS,TP_PHONE)] ON [dbo].[TOPersonalTable] ([TP_SURNAME] ASC, [TP_NAME] ASC, [TP_OTCH] ASC) INCLUDE ([TP_ID], [TP_ID_TO], [TP_ID_RP], [TP_ID_POS], [TP_PHONE]);
GO
GRANT SELECT ON [dbo].[TOPersonalTable] TO rl_all_r;
GRANT SELECT ON [dbo].[TOPersonalTable] TO rl_client_fin_r;
GRANT SELECT ON [dbo].[TOPersonalTable] TO rl_client_r;
GRANT SELECT ON [dbo].[TOPersonalTable] TO rl_fin_r;
GRANT SELECT ON [dbo].[TOPersonalTable] TO rl_to_r;
GO
