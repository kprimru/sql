USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegProtocol]
(
        [RPR_ID]         bigint         Identity(1,1)   NOT NULL,
        [RPR_DATE]       DateTime                           NULL,
        [RPR_ID_HOST]    SmallInt                           NULL,
        [RPR_DISTR]      Int                                NULL,
        [RPR_COMP]       TinyInt                            NULL,
        [RPR_OPER]       VarChar(256)                       NULL,
        [RPR_REG]        TinyInt                            NULL,
        [RPR_TYPE]       VarChar(32)                        NULL,
        [RPR_TEXT]       VarChar(256)                       NULL,
        [RPR_USER]       VarChar(64)                        NULL,
        [RPR_COMPUTER]   VarChar(64)                        NULL,
        [RPR_INSERT]     DateTime                           NULL,
        [RPR_DATE_S]      AS ([dbo].[DateOf]([RPR_DATE])) PERSISTED,
        CONSTRAINT [PK_dbo.RegProtocol] PRIMARY KEY CLUSTERED ([RPR_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.RegProtocol(RPR_DATE)+(RPR_ID_HOST,RPR_DISTR,RPR_COMP,RPR_OPER,RPR_TYPE,RPR_TEXT,RPR_USER,RPR_COMPUTER,RPR_INSERT)] ON [dbo].[RegProtocol] ([RPR_DATE] ASC) INCLUDE ([RPR_ID_HOST], [RPR_DISTR], [RPR_COMP], [RPR_OPER], [RPR_TYPE], [RPR_TEXT], [RPR_USER], [RPR_COMPUTER], [RPR_INSERT]);
CREATE NONCLUSTERED INDEX [IX_dbo.RegProtocol(RPR_DISTR,RPR_ID_HOST,RPR_COMP)] ON [dbo].[RegProtocol] ([RPR_DISTR] ASC, [RPR_ID_HOST] ASC, [RPR_COMP] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.RegProtocol(RPR_OPER,RPR_DATE_S)+(RPR_ID,RPR_DATE,RPR_ID_HOST,RPR_DISTR,RPR_COMP,RPR_REG,RPR_TYPE,RPR_TEXT,RPR_USER,RPR_C] ON [dbo].[RegProtocol] ([RPR_OPER] ASC, [RPR_DATE_S] ASC) INCLUDE ([RPR_ID], [RPR_DATE], [RPR_ID_HOST], [RPR_DISTR], [RPR_COMP], [RPR_REG], [RPR_TYPE], [RPR_TEXT], [RPR_USER], [RPR_COMPUTER], [RPR_INSERT]);
GO
