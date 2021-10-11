USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HostTable]
(
        [HST_ID]         SmallInt       Identity(1,1)   NOT NULL,
        [HST_NAME]       VarChar(250)                   NOT NULL,
        [HST_SHORT]      VarChar(30)                        NULL,
        [HST_REG_NAME]   VarChar(20)                    NOT NULL,
        [HST_REG_FULL]   VarChar(20)                        NULL,
        [HST_ACTIVE]     Bit                            NOT NULL,
        [HST_PSEDO]      VarChar(50)                        NULL,
        CONSTRAINT [PK_dbo.HostTable] PRIMARY KEY CLUSTERED ([HST_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.HostTable()] ON [dbo].[HostTable] ([HST_NAME] ASC);
GO
