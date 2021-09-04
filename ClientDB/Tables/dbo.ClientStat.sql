USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStat]
(
        [FL_NAME]    VarChar(256)       NOT NULL,
        [FL_SIZE]    bigint             NOT NULL,
        [MD5]        VarChar(64)        NOT NULL,
        [FL_DATA]    varbinary          NOT NULL,
        [FL_DATE]    DateTime           NOT NULL,
        [SYS_NUM]    Int                NOT NULL,
        [DISTR]      Int                NOT NULL,
        [COMP]       TinyInt            NOT NULL,
        [OTHER]      VarChar(50)        NOT NULL,
        [DATE]       DateTime           NOT NULL,
        [UPD_USER]   NVarChar(256)      NOT NULL,
        CONSTRAINT [PK_dbo.ClientStat] PRIMARY KEY CLUSTERED ([FL_NAME],[FL_SIZE],[MD5])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStat(DATE)+(SYS_NUM,DISTR,COMP,OTHER)] ON [dbo].[ClientStat] ([DATE] ASC) INCLUDE ([SYS_NUM], [DISTR], [COMP], [OTHER]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStat(DISTR,COMP,SYS_NUM)+(DATE,OTHER,FL_DATE)] ON [dbo].[ClientStat] ([DISTR] ASC, [COMP] ASC, [SYS_NUM] ASC) INCLUDE ([DATE], [OTHER], [FL_DATE]);
GO
