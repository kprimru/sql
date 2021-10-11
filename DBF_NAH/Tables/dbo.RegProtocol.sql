USE [DBF_NAH]
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
        [RPR_OPER]       VarChar(255)                       NULL,
        [RPR_REG]        TinyInt                            NULL,
        [RPR_TYPE]       VarChar(32)                        NULL,
        [RPR_TEXT]       VarChar(256)                       NULL,
        [RPR_USER]       VarChar(64)                        NULL,
        [RPR_COMPUTER]   VarChar(64)                        NULL,
        [RPR_INSERT]     DateTime                           NULL,
        CONSTRAINT [PK_dbo.RegProtocol] PRIMARY KEY CLUSTERED ([RPR_ID]),
        CONSTRAINT [FK_dbo.RegProtocol(RPR_ID_HOST)_dbo.HostTable(HST_ID)] FOREIGN KEY  ([RPR_ID_HOST]) REFERENCES [dbo].[HostTable] ([HST_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.RegProtocol(RPR_DATE,RPR_ID_HOST)+INCL] ON [dbo].[RegProtocol] ([RPR_DATE] ASC, [RPR_ID_HOST] ASC) INCLUDE ([RPR_DISTR], [RPR_COMP], [RPR_OPER], [RPR_REG], [RPR_TYPE], [RPR_TEXT], [RPR_USER], [RPR_COMPUTER]);
CREATE NONCLUSTERED INDEX [IX_dbo.RegProtocol(RPR_ID_HOST,RPR_DISTR,RPR_COMP)] ON [dbo].[RegProtocol] ([RPR_ID_HOST] ASC, [RPR_DISTR] ASC, [RPR_COMP] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.RegProtocol(RPR_OPER)+(RPR_DATE,RPR_ID_HOST,RPR_DISTR,RPR_COMP)] ON [dbo].[RegProtocol] ([RPR_OPER] ASC) INCLUDE ([RPR_DATE], [RPR_ID_HOST], [RPR_DISTR], [RPR_COMP]);
GO
