USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Din].[DinFiles]
(
        [DF_ID]        Int            Identity(1,1)   NOT NULL,
        [DF_ID_SYS]    Int                            NOT NULL,
        [DF_ID_TYPE]   Int                            NOT NULL,
        [DF_ID_NET]    Int                            NOT NULL,
        [DF_DISTR]     Int                            NOT NULL,
        [DF_COMP]      TinyInt                        NOT NULL,
        [DF_RIC]       SmallInt                       NOT NULL,
        [DF_FILE]      VarChar(150)                   NOT NULL,
        [DF_MD5]       VarChar(100)                   NOT NULL,
        [DF_DIN]       varbinary                      NOT NULL,
        [DF_CREATE]    DateTime                       NOT NULL,
        [DF_DATE]       AS ([dbo].[DateOf]([DF_CREATE])) PERSISTED,
        CONSTRAINT [PK_Din.DinFiles] PRIMARY KEY CLUSTERED ([DF_ID]),
        CONSTRAINT [FK_Din.DinFiles(DF_ID_SYS)_Din.SystemTable(SystemID)] FOREIGN KEY  ([DF_ID_SYS]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_Din.DinFiles(DF_ID_NET)_Din.NetType(NT_ID)] FOREIGN KEY  ([DF_ID_NET]) REFERENCES [Din].[NetType] ([NT_ID]),
        CONSTRAINT [FK_Din.DinFiles(DF_ID_TYPE)_Din.SystemType(SST_ID)] FOREIGN KEY  ([DF_ID_TYPE]) REFERENCES [Din].[SystemType] ([SST_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Din.DinFiles(DF_DISTR,DF_COMP)+(DF_ID,DF_ID_SYS,DF_ID_TYPE,DF_ID_NET)] ON [Din].[DinFiles] ([DF_DISTR] ASC, [DF_COMP] ASC) INCLUDE ([DF_ID], [DF_ID_SYS], [DF_ID_TYPE], [DF_ID_NET]);
CREATE NONCLUSTERED INDEX [IX_Din.DinFiles(DF_ID_NET,DF_RIC)+(DF_ID,DF_ID_SYS,DF_ID_TYPE,DF_DISTR,DF_COMP,DF_CREATE)] ON [Din].[DinFiles] ([DF_ID_NET] ASC, [DF_RIC] ASC) INCLUDE ([DF_ID], [DF_ID_SYS], [DF_ID_TYPE], [DF_DISTR], [DF_COMP], [DF_CREATE]);
CREATE NONCLUSTERED INDEX [IX_Din.DinFiles(DF_ID_SYS,DF_ID_TYPE,DF_ID_NET,DF_DISTR,DF_COMP,DF_RIC)] ON [Din].[DinFiles] ([DF_ID_SYS] ASC, [DF_ID_TYPE] ASC, [DF_ID_NET] ASC, [DF_DISTR] ASC, [DF_COMP] ASC, [DF_RIC] ASC);
CREATE NONCLUSTERED INDEX [IX_Din.DinFiles(DF_MD5)] ON [Din].[DinFiles] ([DF_MD5] ASC);
CREATE NONCLUSTERED INDEX [IX_Din.DinFiles(DF_RIC)+(DF_ID,DF_ID_SYS,DF_ID_TYPE,DF_ID_NET,DF_DISTR,DF_COMP,DF_CREATE,DF_DATE)] ON [Din].[DinFiles] ([DF_RIC] ASC) INCLUDE ([DF_ID], [DF_ID_SYS], [DF_ID_TYPE], [DF_ID_NET], [DF_DISTR], [DF_COMP], [DF_CREATE], [DF_DATE]);
GO
