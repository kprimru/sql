USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Protocol]
(
        [PTL_ID]          UniqueIdentifier      NOT NULL,
        [PTL_USER]        VarChar(100)          NOT NULL,
        [PTL_HOST]        VarChar(50)           NOT NULL,
        [PTL_APP]         VarChar(100)              NULL,
        [PTL_DATE]        DateTime              NOT NULL,
        [PTL_REFERENCE]   VarChar(50)           NOT NULL,
        [PTL_REF_NOTE]    VarChar(100)          NOT NULL,
        [PTL_KEY]         UniqueIdentifier      NOT NULL,
        [PTL_OLD_VALUE]   VarChar(Max)              NULL,
        [PTL_NEW_VALUE]   VarChar(Max)              NULL,
        CONSTRAINT [PK_Protocol] PRIMARY KEY NONCLUSTERED ([PTL_ID])
);
GO
CREATE CLUSTERED INDEX [IX_PROTOCOL_DATE] ON [Security].[Protocol] ([PTL_DATE] ASC, [PTL_REFERENCE] ASC, [PTL_KEY] ASC);
CREATE NONCLUSTERED INDEX [IX_PROTOCOL_KEY] ON [Security].[Protocol] ([PTL_KEY] ASC, [PTL_REFERENCE] ASC) INCLUDE ([PTL_USER], [PTL_HOST], [PTL_DATE], [PTL_REF_NOTE]);
GO
