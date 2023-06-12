USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTable]
(
        [SYS_ID]           SmallInt       Identity(1,1)   NOT NULL,
        [SYS_PREFIX]       VarChar(20)                        NULL,
        [SYS_NAME]         VarChar(250)                   NOT NULL,
        [SYS_SHORT_NAME]   VarChar(50)                    NOT NULL,
        [SYS_ID_HOST]      SmallInt                           NULL,
        [SYS_PSEDO]        VarChar(50)                        NULL,
        [SYS_REG_NAME]     VarChar(50)                    NOT NULL,
        [SYS_ID_SO]        SmallInt                           NULL,
        [SYS_ORDER]        SmallInt                           NULL,
        [SYS_REPORT]       Bit                            NOT NULL,
        [SYS_MAIN]         Bit                                NULL,
        [SYS_ACTIVE]       Bit                            NOT NULL,
        [SYS_1C_CODE]      VarChar(50)                        NULL,
        [SYS_WEIGHT]       SmallInt                           NULL,
        [SYS_HOST_REG]     VarChar(50)                        NULL,
        [SYS_COEF]         decimal                            NULL,
        [SYS_IB]           VarChar(50)                        NULL,
        [SYS_CALC]         decimal                            NULL,
        [SYS_GROUP]        VarChar(50)                        NULL,
        [SYS_1C_CODE2]     VarChar(50)                        NULL,
        CONSTRAINT [PK_dbo.SystemTable] PRIMARY KEY CLUSTERED ([SYS_ID]),
        CONSTRAINT [FK_dbo.SystemTable(SYS_ID_HOST)_dbo.HostTable(HST_ID)] FOREIGN KEY  ([SYS_ID_HOST]) REFERENCES [dbo].[HostTable] ([HST_ID]),
        CONSTRAINT [FK_dbo.SystemTable(SYS_ID_SO)_dbo.SaleObjectTable(SO_ID)] FOREIGN KEY  ([SYS_ID_SO]) REFERENCES [dbo].[SaleObjectTable] ([SO_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.SystemTable(SYS_SHORT_NAME)] ON [dbo].[SystemTable] ([SYS_SHORT_NAME] ASC);
GO
