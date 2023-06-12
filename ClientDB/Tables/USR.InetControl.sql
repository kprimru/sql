USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[InetControl]
(
        [IC_ID]            Int                Identity(1,1)   NOT NULL,
        [IC_ID_COMPLECT]   UniqueIdentifier                   NOT NULL,
        [IC_DATE]          DateTime                           NOT NULL,
        [IC_USER]          NVarChar(256)                      NOT NULL,
        [IC_RDATE]         DateTime                               NULL,
        [IC_RUSER]         NVarChar(256)                          NULL,
        CONSTRAINT [PK_USR.InetControl] PRIMARY KEY NONCLUSTERED ([IC_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_USR.InetControl(IC_ID_COMPLECT,IC_ID)] ON [USR].[InetControl] ([IC_ID_COMPLECT] ASC, [IC_ID] ASC);
GO
