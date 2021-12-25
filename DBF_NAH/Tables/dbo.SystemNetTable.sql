USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemNetTable]
(
        [SN_ID]          SmallInt       Identity(1,1)   NOT NULL,
        [SN_NAME]        VarChar(20)                    NOT NULL,
        [SN_FULL_NAME]   VarChar(100)                   NOT NULL,
        [SN_COEF]        decimal                        NOT NULL,
        [SN_ACTIVE]      Bit                            NOT NULL,
        [SN_ORDER]       TinyInt                        NOT NULL,
        [SN_CALC]        decimal                            NULL,
        [SN_ROUND]       TinyInt                        NOT NULL,
        [SN_GROUP]       VarChar(20)                        NULL,
        CONSTRAINT [PK_dbo.SystemNetTable] PRIMARY KEY CLUSTERED ([SN_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_U_SN_FULL_NAME] ON [dbo].[SystemNetTable] ([SN_FULL_NAME] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.SystemNetTable()] ON [dbo].[SystemNetTable] ([SN_NAME] ASC);
GO
