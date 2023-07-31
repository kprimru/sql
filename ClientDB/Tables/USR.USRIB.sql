USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[USRIB]
(
        [UI_ID]        Int             Identity(1,1)   NOT NULL,
        [UI_ID_USR]    Int                                 NULL,
        [UI_ID_BASE]   SmallInt                        NOT NULL,
        [UI_DISTR]     Int                             NOT NULL,
        [UI_COMP]      TinyInt                         NOT NULL,
        [UI_NCAT]      Int                             NOT NULL,
        [UI_NTEXT]     Int                             NOT NULL,
        [UI_N3]        Int                             NOT NULL,
        [UI_N4]        Int                             NOT NULL,
        [UI_N5]        Int                             NOT NULL,
        [UI_N6]        Int                             NOT NULL,
        [UI_ID_COMP]   TinyInt                         NOT NULL,
        [UI_LAST]      SmallDateTime                       NULL,
        CONSTRAINT [PK_USR.USRIB] PRIMARY KEY NONCLUSTERED ([UI_ID]),
        CONSTRAINT [FK_USR.USRIB(UI_ID_USR)_USR.USRFile(UF_ID)] FOREIGN KEY  ([UI_ID_USR]) REFERENCES [USR].[USRFile] ([UF_ID]),
        CONSTRAINT [FK_USR.USRIB(UI_ID_BASE)_dbo.InfoBankTable(InfoBankID)] FOREIGN KEY  ([UI_ID_BASE]) REFERENCES [dbo].[InfoBankTable] ([InfoBankID]),
        CONSTRAINT [FK_USR.USRIB(UI_ID_COMP)_dbo.ComplianceTypeTable(ComplianceTypeID)] FOREIGN KEY  ([UI_ID_COMP]) REFERENCES [dbo].[ComplianceTypeTable] ([ComplianceTypeID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_USR.USRIB(UI_ID_USR,UI_ID_BASE)] ON [USR].[USRIB] ([UI_ID_USR] ASC, [UI_ID_BASE] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRIB(UI_DISTR,UI_ID_BASE,UI_COMP,UI_LAST)+(UI_ID_COMP,UI_ID_USR)] ON [USR].[USRIB] ([UI_DISTR] ASC, [UI_ID_BASE] ASC, [UI_COMP] ASC, [UI_LAST] ASC) INCLUDE ([UI_ID_COMP], [UI_ID_USR]);
GO
